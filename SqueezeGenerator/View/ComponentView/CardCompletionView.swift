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
    @Binding var needIllustration: Bool

    var body: some View {
        VStack {
            VStack {
                Text("Great job!")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white.opacity(.Opacity.separetor.rawValue))
                    .shadow(color:.black.opacity(0.1), radius: 10)
                Button {
                    needIllustration.toggle()
                    //                viewModel.donePressed(viewModel.selectedOptions)
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
            .offset(y: -120)
        }

        .frame(maxHeight: .infinity)
        .background {
            VStack {
                Spacer().frame(maxHeight: .infinity)
                PlanetIllustration(needIllustration: needIllustration)
            }
            .ignoresSafeArea(.all)

        }
    }

    private var isLight: Bool {
        tintColor.isLight
    }
}

fileprivate struct PlanetIllustration: View {
    let needIllustration: Bool
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: .zero) {
            Spacer().frame(maxHeight: .infinity)
            topPlanet
            firstPlanet
                .overlay(content: {
                    leftPlanet
                })
            Image(.CardCompletionIllustration.Planet.graund)
        }
        .frame(maxHeight: needIllustration ? .infinity : 0)
        .clipped()
        .animation(.smooth(duration: 1.2), value: needIllustration)
        .onAppear {
            animate.toggle()
        }
    }

    private var topPlanet: some View {
        HStack {
            Spacer()
                .frame(maxWidth: .infinity)
            VStack(content: {
                Image(.CardCompletionIllustration.Planet.planet3)
                    .frame(width: 160, height: 160)
            })
            .rotationEffect(
                .degrees(animate ? -360 : 0)
            )
            .animation(
                .easeInOut(duration: 3.9)
                .repeatForever(autoreverses: false)
                .speed(0.9),
                value: animate
            )
            Spacer()
                .frame(maxWidth: .infinity)

        }
        .offset(x: 0, y: 80)
    }

    private var leftPlanet: some View {
        HStack {
            VStack(content: {
                Image(.CardCompletionIllustration.Planet.planet2)
                    .frame(width: 100, height: 100)
            })
            .rotation3DEffect(
                .degrees(animate ? -10 : 30),
                axis: (x: 0, y: 0, z: 1)
            )
            .animation(
                .linear(duration: 5.9)
                .repeatForever(autoreverses: true)
                .speed(0.3),
                value: animate
            )
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .offset(x: -70)

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
        .offset(x: 70, y: needIllustration ? 70 : 150)
        .frame(maxHeight: needIllustration ? .infinity : 0)
        .animation(.smooth(duration: 1.8), value: needIllustration)
    }
}
