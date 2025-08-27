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
                Color.black.opacity(0.8)
                    .ignoresSafeArea(.all)
                    .allowsTightening(true)
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
                        .onChange(of: appService.tutorialManager.frame) { newValue in
                            print(newValue.minY, " gterfwedqaws ")
                        }
                    Spacer().frame(maxHeight: .infinity)
                }

                Text("Tutorial")
                    .font(.title)
                    .disabled(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .compositingGroup()
            .allowsHitTesting(false)
            .ignoresSafeArea(.all)
            .onAppear {
                print(proxy.frame(in: .global), " grefwdsefd ")
                print(proxy.frame(in: .local), " grefwdsefd ")

            }
            .onChange(of: proxy.frame(in: .global)) { newValue in
                print(proxy.frame(in: .global), " grefwdsefd ")
                print(proxy.frame(in: .local), " grefwdsefd ")
            }
        }
    }
}

#Preview {
    TutorialNavigationView()
}
