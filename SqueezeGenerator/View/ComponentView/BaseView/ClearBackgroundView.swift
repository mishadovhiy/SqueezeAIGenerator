//
//  ClearBackgroundView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 21.07.2025.
//

import SwiftUI

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
            view.superview?.superview?.superview?.backgroundColor = .clear
            view.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
