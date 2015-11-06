//
//  Constants.swift
//  VDMapCacherExample
//
//  Created by Vadim Drobinin on 5/11/15.
//  Copyright © 2015 Vadim Drobinin. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Constants {
    // (lat, lon) of cities
    static let ny = CLLocationCoordinate2D(latitude: 40.642334, longitude: -73.78817)
    static let moscow = CLLocationCoordinate2D(latitude: 55.775444, longitude: 37.5787786)
    static let saint = CLLocationCoordinate2D(latitude: 59.9174925, longitude: 30.0448836)
    static let tokyo = CLLocationCoordinate2D(latitude: 35.6735408, longitude: 139.5703033)
    static let sydney = CLLocationCoordinate2D(latitude: -33.7960361, longitude: 150.6422481)
    static let la = CLLocationCoordinate2D(latitude: 34.0207504, longitude: -118.6919206)
    static let beijing = CLLocationCoordinate2D(latitude: 39.9390731, longitude: 116.1172735)
    static let dehli = CLLocationCoordinate2D(latitude: 28.6457559, longitude: 76.8105672)
    
    static let Moscow = CGPointMake(55.751244, 37.618423)
    static let Lisbon = CGPointMake(38.736946, -9.142685)
    static let NY = CGPointMake(42.3482, -75.1890)
    
    static let latDelta: CLLocationDegrees = 180 // Span level
    static let lngDelta: CLLocationDegrees = 180
    
    static let heightSize: CGFloat = 200 // Image height
    
    // Directions for the plane
    static let left = "Left"
    static let right = "Right"
    static let up = "Up"
    static let down = "Down"
    static let straight = "Straight"
    static let name = "plane"
    
    // Image settings
    static let imageDelta: CGFloat = 10
    static let imageWidth: CGFloat = 20
    static let imageHeight: CGFloat = 20
}