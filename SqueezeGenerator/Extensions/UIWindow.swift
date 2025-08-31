//
//  UIWindow.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import UIKit

extension UIWindow: @retroactive UIGestureRecognizerDelegate {
    
    static var activeWindowName: String = ""

    var isActive: Bool {
        UIWindow.activeWindowName == self.layer.name
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.layer.name?.isEmpty ?? true {
            self.layer.name = UUID().uuidString
        }
        UIWindow.activeWindowName = self.layer.name ?? ""
        return super.hitTest(point, with: event)
    }
}
