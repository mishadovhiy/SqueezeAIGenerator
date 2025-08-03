//
//  UIApplication.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 04.08.2025.
//

import UIKit

extension UIApplication {
    var safeArea: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first(where: {
            $0.isKeyWindow
        })?.safeAreaInsets ?? (scene?.windows.first(where: {
            $0.safeAreaInsets != .zero
        })?.safeAreaInsets ?? .zero)
    }
}
