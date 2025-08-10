//
//  Font.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 10.08.2025.
//

import SwiftUI

extension Font {
    typealias `Type` = Configuration.UI.FontType
}

extension Text {
    func styled(_ type: Configuration.UI.FontType,
                opacity: CGFloat? = nil) -> some View {
        self
            .font(type.font)
            .opacity(opacity ?? type.opacity)
    }
}
