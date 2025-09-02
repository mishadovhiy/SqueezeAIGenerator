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
                Color.black.opacity(appService.tutorialManager.type == nil ? 0.4 : 0.6)
                    .ignoresSafeArea(.all)
                    .animation(.smooth, value: appService.tutorialManager.type == nil)
                blendOutComposition
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                rulesView
            }
            .compositingGroup()
            .allowsHitTesting(false)
            .ignoresSafeArea(.all)
            .overlay(content: {
                typeTextOverlay
            })
            .overlay {
                skipButton
            }
        }
    }
    
    var attributedString: AttributedString {
        let mut: NSMutableAttributedString = .init()
        mut.append(.init(string: "Generate Queez", attributes: [
            .font: UIFont.systemFont(ofSize: 28, weight: .semibold)
        ]))
        mut.append(.init(string: " on any category", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]))
        return .init(mut)
    }
    
    var rulesView: some View {
        VStack(alignment: .leading) {
            Text(attributedString)//on any category - small
            Text("Generating with AI")
                .font(.system(size: 12, weight: .regular))
        }
        .frame(alignment: .leading)
        .padding(.horizontal, 10)
        .blendMode(.destinationOut)
        .opacity(appService.tutorialManager.type == DataBase.Tutorial.TutorialType.allCases.first ? 1 : 0)
        .animation(.smooth, value: appService.tutorialManager.type == DataBase.Tutorial.TutorialType.allCases.first)
    }
    
    var skipButton: some View {
        VStack(alignment: .trailing) {
            Button {
                appService.tutorialManager.skipPressed = true
                appService.tutorialManager.type = nil
            } label: {
                VStack {
                    Text("Skip")
                        .font(.system(size: 12, weight: .medium))
                    Text("You can restart later")
                        .font(.system(size: 7, weight: .light))
                        .opacity(0.4)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 4)
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(5)
            }
            .frame(alignment: .trailing)
            .shadow(radius: 9)
            Spacer()
        }
        .opacity(appService.tutorialManager.type == DataBase.Tutorial.TutorialType.allCases.first ? 1 : 0)
        .animation(.smooth, value: appService.tutorialManager.type == DataBase.Tutorial.TutorialType.allCases.first)
        .padding(.top, 5)
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
    
    var previousTypeButton: some View {
        Button {
            let newIndex = (appService.tutorialManager.type?.index ?? 0) - 1
            if newIndex >= 0 && newIndex <= DataBase.Tutorial.TutorialType.allCases.count - 1 {
                appService.tutorialManager.type = DataBase.Tutorial.TutorialType.allCases[newIndex]
            } else {
                appService.tutorialManager.type = DataBase.Tutorial.TutorialType.allCases.first
            }
        } label: {
            Image(.arrowDown)
                .resizable()
                .scaledToFit()
                .frame(height: 15)
                .frame(maxWidth: .infinity)
                .rotationEffect(.degrees(90))
                .padding(.vertical, 3)
                .background(.black.opacity(0.15))
                .cornerRadius(5)
                .foregroundColor(.black)
        }
        .frame(maxWidth: appService.tutorialManager.type != DataBase.Tutorial.TutorialType.allCases.first ? 50 : 0)
        .clipped()
        .animation(.smooth, value: appService.tutorialManager.type != DataBase.Tutorial.TutorialType.allCases.first)
    }
    
    @ViewBuilder
    var typeTextOverlay: some View {
        let frameY = appService.tutorialManager.frame
            .minY - 100
        VStack {
            HStack(content: {
                previousTypeButton

                Text(appService.tutorialManager.type?.rawValue.addSpaceBeforeCapitalizedLetters.capitalized ?? "Well done!\nTutorial Completed!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .disabled(true)
                    .transition(.move(edge: .leading))
                    .animation(.smooth, value: appService.tutorialManager.type)
                    .blendMode(.destinationOut)
            })
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(content: {
                    Color.white
                        .cornerRadius(6)
                        .opacity(0.4)
                        .shadow(radius: 10)
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
