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
        imageViewClear.image = imageResize(snapshot, sizeChange: CGSize(width: 320, height: 300))
    }
}

class OverviewViewController: UIViewController {
    @IBOutlet weak var imageViewClear: UIImageView!
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 1900, height: 1000))
    let mapCacher = VDMapCacher()
    
    func setUpCacher() {
        mapCacher.delegate = self
        mapCacher.departureCoords = [Constants.moscow, Constants.ny, Constants.saint]
        mapCacher.arrivalCoords = [Constants.sydney, Constants.dehli, Constants.tokyo]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCacher()
        mapCacher.generateMapForRouteInView(imageView, line: 6.0, size: CGSize(width: 1900, height: 1000))
    }


}

