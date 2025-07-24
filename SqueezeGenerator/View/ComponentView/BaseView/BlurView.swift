//
//  BlurView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 24.07.2025.
//

import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .init(rawValue: 999)!))
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

