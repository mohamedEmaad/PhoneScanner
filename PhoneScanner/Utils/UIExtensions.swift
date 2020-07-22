//
//  UIExtensions.swift
//  MedicineTracker
//
//  Created by Mohamed Emad on 7/12/20.
//  Copyright © 2020 Medicine Tracker. All rights reserved.
//

import Foundation

extension CGRect {

    var centerPoint: CGPoint {
        let origin = self.origin
        let x = origin.x
        let y = origin.y
        return CGPoint(x: (x + (self.width / 2)), y: (y + (self.height / 2)))
    }

}

extension CGPoint {

    func distance(to point: CGPoint) -> CGFloat {
        let floatDistace = hypotf(Float(self.x - point.x), Float(self.y - point.y))
        return CGFloat(floatDistace)
    }

}

extension UIView {

    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.

    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
