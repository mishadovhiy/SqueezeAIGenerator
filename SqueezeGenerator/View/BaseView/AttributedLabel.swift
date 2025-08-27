//
//  AttributedLabel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 28.07.2025.
//

import SwiftUI
import UIKit

struct AttributedLabel: UIViewRepresentable {
    let text: NSAttributedString
    let textColor: UIColor
    
    func makeUIView(context: Context) -> some UILabel {
        let label = UILabel()
        label.text = text.string//.attributedText = text
        label.textColor = textColor
        label.numberOfLines = 0
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
//        uiView.attributedText = text
        uiView.text = text.string
        if let superview = uiView.superview {
                    NSLayoutConstraint.activate([
                        uiView.widthAnchor.constraint(equalToConstant: superview.frame.width)
                    ])
                }
    }
}

