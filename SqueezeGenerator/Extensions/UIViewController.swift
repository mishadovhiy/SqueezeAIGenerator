//
//  UIViewController.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import UIKit

extension UIViewController {
    func present(_ viewController: UIViewController) {
        if let vc = self.presentedViewController {
            vc.present(viewController)
        } else {
            self.present(viewController, animated: true)
        }
    }

    var topViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topViewController
        } else {
            return self
        }
    }
}
