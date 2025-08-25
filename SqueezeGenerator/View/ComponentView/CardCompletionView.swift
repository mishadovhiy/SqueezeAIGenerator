//
//  CardCompletionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 25.08.2025.
//

import SwiftUI

struct CardCompletionView: View {
    let viewModel: CardsViewModel
    let tintColor: UIColor
    var isLight: Bool {
        tintColor.isLight
    }

    var body: some View {
        VStack {
            Text("Great job!")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white.opacity(.Opacity.separetor.rawValue))
                .shadow(color:.black.opacity(0.1), radius: 10)
            Button {
                viewModel.donePressed(viewModel.selectedOptions)
            } label: {
                Text("Get Results")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                    .foregroundColor(isLight ? .black : .white)
            }
            .background(Color(uiColor: tintColor))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isLight ? .black : .white, lineWidth: 1)
                    .opacity(0.2)
            }
            .cornerRadius(12)
            .shadow(color: .init(uiColor: tintColor), radius: 12)
        }
        .frame(maxHeight: .infinity)
        .background {
            VStack {
                Spacer().frame(maxHeight: .infinity)
                PlanetIllustration()
            }
            .ignoresSafeArea(.all)

        }
    }
}

fileprivate struct PlanetIllustration: View {

    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: .zero) {
            Spacer().frame(maxHeight: .infinity)
            firstPlanet
            Image(.CardCompletionIllustration.Planet.graund)
        }
        .onAppear {
            animate.toggle()
        }
    }

    private var firstPlanet: some View {
        VStack {
            VStack(content: {
                Image(.CardCompletionIllustration.Planet.planet1)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            })
            .rotationEffect(
                .degrees(animate ? 360 : 0)
            )
            .animation(
                .linear(duration: 5.9)
                .repeatForever(autoreverses: false)
                .speed(0.9),
                value: animate
            )
        }
        .offset(x: 70, y: 70)
    }
}
