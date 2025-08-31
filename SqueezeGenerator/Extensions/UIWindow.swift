//
//  UIWindow.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import UIKit

extension UIWindow: @retroactive UIGestureRecognizerDelegate {

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        #warning("implement: current window setter")
        return super.hitTest(point, with: event)
    }
}
