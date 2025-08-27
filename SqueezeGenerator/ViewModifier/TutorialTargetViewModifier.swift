//
//  TutorialTargetViewModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

/// sets frame of the content, for current matching target.
/// - frame used in 'TutorialModifier'
struct TutorialTargetViewModifier: ViewModifier {
    @EnvironmentObject var appService: AppServiceManager
    let targetType: DataBase.Tutorial.TutorialType
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            if targetType == appService.tutorialManager.current {
                                appService.tutorialManager.frame = proxy.frame(in: .global)
                                print(appService.tutorialManager.frame, " ytregfwd")

                            }

                        }
                        .onChange(of: proxy.frame(in: .global)) { newValue in
                            if targetType == appService.tutorialManager.current {
                                appService.tutorialManager.frame = newValue
                                print(newValue, " ytregfwd")
                            }

                        }
                        .onChange(of: appService.tutorialManager.current) { newValue in
                            print(newValue, " gyterfwdas ")
                            if newValue == targetType {
                                if targetType == .selectType {
                                    print(proxy.frame(in: .global), " yterfweds ")
                                }
                                appService.tutorialManager.frame = proxy.frame(in: .global)
                            }
                        }
                }
            }

    }

}
