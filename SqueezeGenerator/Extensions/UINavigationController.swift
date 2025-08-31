//
//  UINavigationController.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import UIKit

extension UINavigationController: UIScrollViewDelegate, UINavigationControllerDelegate {
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
#warning("no need: testing")
        SqueezeGeneratorApp.navigationHeight(with: navigationBar.frame.size.height ?? 0)
    }
}
