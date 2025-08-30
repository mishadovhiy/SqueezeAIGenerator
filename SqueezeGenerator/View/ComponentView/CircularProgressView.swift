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
    let imageURL: String?
    let color: UIColor

    init(
        progress: CGFloat,
        title: String? = nil,
        widthMultiplier: CGFloat = 1,
        imageURL: String?,
        color: UIColor
    )
    {
        self.widthMultiplier = widthMultiplier
        self.progress = progress
        self.title = title ?? "Your score"
        self.imageURL = imageURL
        self.color = color
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color(uiColor: color).opacity(0.3))
                    Circle()
                        .inset(by: proxy.size.width / 4)
                        .trim(from: 0, to: progress)
                        .stroke(Color(uiColor: color).opacity(0.6), style: StrokeStyle(lineWidth: proxy.size.width / 2))
                        .rotationEffect(.radians(-.pi/2))
                        .animation(.linear, value: progress)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(uiColor: color), lineWidth: 6)
                        .rotationEffect(.radians(-.pi/2))
                        .shadow(radius: 10)
                    

                }
            }
            .frame(width: 150 * widthMultiplier, height: 150 * widthMultiplier)
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 32 * widthMultiplier, weight: .bold))
                    .overlay {
                        Text("%")
                            .font(.system(size: 15 * widthMultiplier, weight: .bold))
                            .frame(width: 30)
                            .multilineTextAlignment(.leading)
                            .offset(x: 30)
                    }
                Text(title)
                    .font(.system(size: 9 * widthMultiplier, weight: .semibold))
                    .opacity(widthMultiplier >= 0.5 ? 0.4 : 0)
                    .animation(.smooth, value: widthMultiplier >= 0.5)
                
            }
            .blendMode(.destinationOut)

        }
        .compositingGroup()
    }
}
