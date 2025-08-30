//
//  BlurView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 28.07.2025.
//

import UIKit
import SwiftUI

struct BlurView: View {
    
    let count: Int
    
    init(count: Int = 1) {
        self.count = count
    }
    
    var body: some View {
        ForEach(0..<count, id: \.self) { _ in
            BlurViewRepresentable()
        }
    }
}

fileprivate struct BlurViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .init(rawValue: 999)!))
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
