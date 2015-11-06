//
//  ListViewController.swift
//  VDMapCacherExample
//
//  Created by Vadim Drobinin on 5/11/15.
//  Copyright © 2015 Vadim Drobinin. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let mapCacher = VDMapCacher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpCacher()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: Set Up

extension ListViewController {
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
        tableView.registerNib(UINib(nibName: "MapTableViewCell", bundle: nil), forCellReuseIdentifier: "MapTableViewCell")
    }
    
    func setUpCacher() {
        mapCacher.delegate = self
        mapCacher.departureCoords = [Constants.dehli]
        mapCacher.arrivalCoords = [Constants.beijing]
    }
}

// MARK: ImageGeneratedProtocol

extension ListViewController: ImageGeneratedProtocol {
    func update() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        cell?.setNeedsLayout()
        addPlanesToTheMap(cell) // Uncomment for a demo of planes displaying feature
    }
}

// MARK: Plane Drawing

extension ListViewController {
    func addPlanesToTheMap(cell: UITableViewCell?) {
        for i in 0..<mapCacher.departureCoords!.count {
            let midpointLoc = mapCacher.findMidpointBetweenPoint(mapCacher.departureCoords![i], andPoint: mapCacher.arrivalCoords![i])
            let midpoint = mapCacher.geodesicProj(midpointLoc)
            drawThePlaneAtPoint(mapCacher.departureCoords![i], inView: cell?.imageView, pair: i)
            drawThePlaneAtPoint(midpoint, inView: cell?.imageView, pair: i)
            drawThePlaneAtPoint(mapCacher.arrivalCoords![i], inView: cell?.imageView, pair: i)
        }
    }
    
    func determineDirection(i: Int) -> String {
        if (mapCacher.arrivalCoords?[i].longitude < mapCacher.departureCoords?[i].longitude) {
            return Constants.left
        } else {
            return Constants.right
        }
    }
    
    func determinePartInDirection(direction: String, withPoint point: CLLocationCoordinate2D, forItem i: Int) -> String {
        let absPath = abs((mapCacher.departureCoords?[i].latitude ?? 0) - (mapCacher.arrivalCoords?[i].latitude ?? 0))
        let absLocation = abs((mapCacher.departureCoords?[i].latitude ?? 0) - point.latitude)
        let proportion = absPath / absLocation
        
        if proportion.isInfinite {
            return Constants.up
        }
        switch proportion {
        case 0.85...1.15:
            return Constants.down
        case -0.15...0.15:
            return Constants.up
        default:
            return Constants.straight
        }
    }
    
    func getPictureForPoint(point: CLLocationCoordinate2D?, i: Int) -> UIImage? {
        guard let point = point else {
            return UIImage(named: "failure")
        }
        let direction = determineDirection(i)
        let part = determinePartInDirection(direction, withPoint: point, forItem: i)
        let name = Constants.name + part + direction
        return UIImage(named: name)
    }
    
    func drawThePlaneAtPoint(coords: CLLocationCoordinate2D, inView view: UIImageView?, pair: Int) {
        guard let view = view else {
            return
        }
        let convertedCoords = mapCacher.convertCoordinates(coords)
        let rect = CGRectMake((convertedCoords?.x ?? 0) - 10, (convertedCoords?.y ?? 0) - Constants.imageDelta, Constants.imageWidth, Constants.imageHeight)
        
        let planePath = UIImageView(frame: rect)
        planePath.image = getPictureForPoint(coords, i: pair)
        view.addSubview(planePath)
        
    }
}

// MARK: UITableViewDelegate

extension ListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.heightSize
    }
}

// MARK: UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MapTableViewCell = tableView.dequeueReusableCellWithIdentifier("MapTableViewCell", forIndexPath: indexPath) as! MapTableViewCell
        mapCacher.generateMapForRouteInView(cell.imageView, line: 2.0)
        return cell
    }
}
