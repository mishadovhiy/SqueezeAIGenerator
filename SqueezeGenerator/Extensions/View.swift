//
//  View.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 10.08.2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func blurBackground(_ shema: ColorScheme = .light,
                        opacityMultiplier: CGFloat = 1,
                        opacity: CGFloat? = nil,
                        cornerRadius: CGFloat = .CornerRadius.large.rawValue,
                        padding: CGFloat = .zero
    ) -> some View {
        let defaultOpacity:CGFloat = shema == .light ? .Opacity.lightBackground.rawValue : .Opacity.background.rawValue
        self
            .background(content: {
                BlurView()
            })
            .background(
                (Color(
                    uiColor: shema == .dark ? .black : .white)
                ).opacity(
                    (opacity ?? defaultOpacity) * opacityMultiplier
                )
                
            )
            .cornerRadius(cornerRadius)
    }
}

extension Button {
    func smallButtonStyle() -> some View {
        self
            .tint(.black)
            .padding(8)
            .padding(.leading, 9)
            .frame(width: .Padding.smallButtonSize.rawValue,
                   height: .Padding.smallButtonSize.rawValue)
            .blurBackground(cornerRadius: .CornerRadius.button.rawValue)
    }
}
