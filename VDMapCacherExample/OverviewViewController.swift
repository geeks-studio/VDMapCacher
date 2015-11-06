//
//  OverviewViewController.swift
//  VDMapCacherExample
//
//  Created by Vadim Drobinin on 5/11/15.
//  Copyright © 2015 Vadim Drobinin. All rights reserved.
//

import UIKit
import CoreLocation

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension OverviewViewController: ImageGeneratedProtocol {
    func imageResize(imageObj: UIImage, sizeChange: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    func update() {
        imageView.setNeedsLayout()
        let snapshot = imageView.snapshot()
        imageView.layer.sublayers = nil
        imageView.image = imageResize(snapshot, sizeChange: CGSize(width: 320, height: 300))
    }
}

class OverviewViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    let mapCacher = VDMapCacher()
    
    func setUpCacher() {
        mapCacher.delegate = self
        mapCacher.departureCoords = [Constants.sydney, Constants.moscow, Constants.ny]
        mapCacher.arrivalCoords = [Constants.tokyo, Constants.sydney, Constants.dehli]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCacher()
        mapCacher.generateMapForRouteInView(imageView, line: 2.0, size: CGSize(width: 320, height: 300))
    }


}

