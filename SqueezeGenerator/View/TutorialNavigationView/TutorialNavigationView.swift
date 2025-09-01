//
//  TutorialNavigationView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

struct TutorialNavigationView: View {
    @EnvironmentObject var appService: AppServiceManager

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(appService.tutorialManager.type == nil ? 0.4 : 0.8)
                    .ignoresSafeArea(.all)
                    .animation(.smooth, value: appService.tutorialManager.type == nil)
                blendOutComposition
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .compositingGroup()
            .allowsHitTesting(false)
            .ignoresSafeArea(.all)
            .overlay(content: {
                typeTextOverlay
            })
        }
    }
    
    var blendOutComposition: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.red)
                .frame(
                    width: appService.tutorialManager.frame.width,
                    height: appService.tutorialManager.frame.height
                )
                .offset(
                    x: appService.tutorialManager.frame.minX,
                    y:  appService.tutorialManager.frame
                        .minY
                )
                .ignoresSafeArea(.all)
                .blendMode(.destinationOut)
            Spacer().frame(maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var typeTextOverlay: some View {
        let frameY = appService.tutorialManager.frame
            .minY - 100
        VStack {
            Text(appService.tutorialManager.type?.rawValue.addSpaceBeforeCapitalizedLetters.capitalized ?? "Well done!\nTutorial Completed!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .disabled(true)
                .transition(.move(edge: .leading))
                .animation(.smooth, value: appService.tutorialManager.type)
                .blendMode(.destinationOut)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(content: {
                    Color.white
                        .cornerRadius(6)
                })
                .offset(y: frameY >= 0 ? frameY : 0)

            Spacer()
        }
        .compositingGroup()
    }
}

#Preview {
    TutorialNavigationView()
}
