//
//  CircularProgressView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 24.08.2025.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat
    let title: String
    let widthMultiplier: CGFloat

    init(
        progress: CGFloat,
        title: String? = nil,
        widthMultiplier: CGFloat = 1)
    {
        self.widthMultiplier = widthMultiplier
        self.progress = progress
        self.title = title ?? "Your score"
    }

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.red, lineWidth: 3)
            }
            .frame(width: 150 * widthMultiplier)
            .aspectRatio(1, contentMode: .fit)
            VStack {
                Text(title)
                    .font(.system(size: 9 * widthMultiplier, weight: .semibold))
                    .opacity(widthMultiplier >= 0.5 ? 0.4 : 0)
                    .animation(.smooth, value: widthMultiplier >= 0.5)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32 * widthMultiplier, weight: .bold))
            }
        }
    }
}
