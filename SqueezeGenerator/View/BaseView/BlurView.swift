//
//  BlurView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 28.07.2025.
//

import UIKit
import SwiftUI

struct BlurView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .init(rawValue: 999)!))
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
