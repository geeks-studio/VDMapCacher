//
//  VDMapCasher.swift
//
//  Created by Vadim Drobinin on 5/10/15.
//  Copyright © 2015 Vadim Drobinin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

// MARK: Protocols

protocol ImageGeneratedProtocol {
    func update()
}

// MARK:

class VDMapCacher {
    var snapshot: MKMapSnapshot?
    var coords: [CLLocationCoordinate2D] = []
    var delegate: ImageGeneratedProtocol?
    var departureCoords: [CLLocationCoordinate2D]?
    var arrivalCoords: [CLLocationCoordinate2D]?
    
    // MARK: Coordinate Helpers
    
    func geodesicProj(point: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var deltaX: Double = 100
        var deltaY: Double = 100
        var idx = 0
        
        for i in 1..<coords.count {
            if (abs(point.latitude - coords[i].latitude) < deltaX) && (abs(point.longitude - coords[i].longitude) < deltaY) {
                deltaX = abs(point.latitude - coords[i].latitude)
                deltaY = abs(point.longitude - coords[i].longitude)
                idx = i
            }
        }
        return coords[idx]
    }
    
    func convertTo2DFromPoint(point: CGPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(point.x),
                                      longitude: CLLocationDegrees(point.y))
    }
    
    func convertCoordinates(coordinates: CLLocationCoordinate2D) -> CGPoint? {
        return snapshot?.pointForCoordinate(coordinates)
    }
    
    func findMidpointBetweenPoint(a: CLLocationCoordinate2D, andPoint b: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // (lon, lat) in [0..360]
        let lon1: Double = a.longitude * M_PI / 180
        let lon2: Double = b.longitude * M_PI / 180
        let lat1: Double = a.latitude * M_PI / 180
        let lat2: Double = b.latitude * M_PI / 180
        
        let dLon: Double = lon2 - lon1
        let x: Double = cos(lat2) * cos(dLon)
        let y: Double = cos(lat2) * sin(dLon)
        let lat3: Double = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y))
        let lon3: Double = lon1 + atan2(y, cos(lat1) + x)
        
        return CLLocationCoordinate2D(latitude: lat3 * 180 / M_PI - 5, longitude: lon3 * 180 / M_PI + 15)
    }

    // MARK: Geodesic
    func createPolylineFromPoint(start: CLLocationCoordinate2D, toPoint end: CLLocationCoordinate2D, ofColor lineColor: UIColor, inView view: UIView?, line: CGFloat) {
        guard let view = view else {
            print("The view is broken")
            return
        }
        
        // Extract coordinates of geodesic points
        var points: [CLLocationCoordinate2D] = [start, end]
        coords = []
        let geodesic = MKGeodesicPolyline(coordinates: &points[0], count: 2)
        let coordinatePointers = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(geodesic.pointCount)
        geodesic.getCoordinates(coordinatePointers, range: NSMakeRange(0, geodesic.pointCount))
        for i in 0..<geodesic.pointCount {
            coords.append(coordinatePointers[i])
        }
        coordinatePointers.dealloc(geodesic.pointCount)
        
        // Draw the path
        let path = UIBezierPath()
        if let snapshot = snapshot {
            for (idx, elem) in coords.enumerate() {
                let point = snapshot.pointForCoordinate(elem)
                if (idx == 0) {
                    path.moveToPoint(point)
                } else {
                    path.addLineToPoint(point)
                }
            }
        }
        
        // Set properties and append to the view
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.lineWidth = line
        view.layer.addSublayer(shapeLayer)
    }
    
    func requestSnapshotDataOfSize(size: CGSize, region: MKCoordinateRegion, completion: (image: UIImage, error: NSError!) -> ()) {
        // Set up the snapshotter
        let options = MKMapSnapshotOptions()
        options.region = region
        options.size = size
        options.scale = UIScreen.mainScreen().scale
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler() { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion(image: UIImage(named: "failure") ?? UIImage(), error: error)
                return
            }
            
            let image = snapshot!.image
            self.snapshot = snapshot
            completion(image: image, error: nil)
        }
    }
    
    func closedConvexHull(points_ : [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        
        func cross(P: CLLocationCoordinate2D, A: CLLocationCoordinate2D, B: CLLocationCoordinate2D) -> CGFloat {
            let part1 = (A.latitude - P.latitude) * (B.longitude - P.longitude)
            let part2 = (A.longitude - P.longitude) * (B.latitude - P.latitude)
            return  CGFloat(part1 - part2)
        }
        
        // Sort points lexicographically
        let points = points_.sort() {
            $0.latitude == $1.latitude ? $0.longitude < $1.longitude : $0.latitude < $1.latitude
        }
        
        // Build the lower hull
        var lower: [CLLocationCoordinate2D] = []
        for p in points {
            while lower.count >= 2 && cross(lower[lower.count-2], A: lower[lower.count-1], B: p) <= 0 {
                lower.removeLast()
            }
            lower.append(p)
        }
        
        // Build upper hull
        var upper: [CLLocationCoordinate2D] = []
        for p in points.reverse() {
            while upper.count >= 2 && cross(upper[upper.count-2], A: upper[upper.count-1], B: p) <= 0 {
                upper.removeLast()
            }
            upper.append(p)
        }
        
        // Last point of upper list is omitted because it is repeated at the
        // beginning of the lower list.
        upper.removeLast()
        
        // Concatenation of the lower and upper hulls gives the convex hull.
        upper.appendContentsOf(lower)
        return upper
    }
    
    func generateMapForRouteInView(imageView: UIImageView?, line: CGFloat, size: CGSize) {
        // Find the midpoint to use as the center of the region
        let a = closedConvexHull(departureCoords!)[0]
        let b = closedConvexHull(arrivalCoords!)[0]
        let midpoint = findMidpointBetweenPoint(a, andPoint: b)
        
        let theSpan = MKCoordinateSpanMake(CLLocationDegrees(180), CLLocationDegrees(180))
        let theRegion = MKCoordinateRegionMake(midpoint, theSpan)
//        let theRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
        
        if let imageView = imageView {
            requestSnapshotDataOfSize(size, region: theRegion) { (image, error) -> () in
                if error != nil {
                    imageView.image = UIImage(named: "failure")!
                } else {
                    imageView.image = image
                    // Draw the geodesic
                    for i in 0..<self.departureCoords!.count {
                        self.createPolylineFromPoint(self.departureCoords![i], toPoint: self.arrivalCoords![i], ofColor: .redColor(), inView: imageView, line: line)
                    }
                    self.delegate?.update()
                }
            }
            
        }
    }
    
    func generateMapForRouteInView(imageView: UIImageView?, line: CGFloat) {
        if let imageView = imageView {
            let height = imageView.bounds.height != 0 ? imageView.bounds.height : Constants.heightSize
            generateMapForRouteInView(imageView, line: line, size: CGSize(width: UIScreen.mainScreen().bounds.size.width, height: height))
        }
    }
    
}