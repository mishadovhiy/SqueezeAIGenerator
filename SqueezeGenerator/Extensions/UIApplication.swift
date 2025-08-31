//
//  UIApplication.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 04.08.2025.
//

import UIKit

extension UIApplication {
    var safeArea: UIEdgeInsets {
        return activeWindow?.safeAreaInsets ?? .zero
    }
    
    var activeWindow: UIWindow? {
        let scene = self.connectedScenes.first as? UIWindowScene
        return scene?.windows.first(where: {
            $0.isKeyWindow && $0.isActive
        })
    }
}
