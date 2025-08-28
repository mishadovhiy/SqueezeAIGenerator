//
//  TutorialModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

///- waits for TutorialType to be setted to nil
struct TutorialModifier: ViewModifier, TutorialModifierUIService {
    @EnvironmentObject var appService: AppServiceManager
    @EnvironmentObject var db: LocalDataBaseManager
    @State var appAppeared: Bool = false
    @State private var currentService: DataBase.Tutorial.TutorialType?

    func body(content: Content) -> some View {
        content
            .overlay {
                if appService.tutorialManager.needTutorial {
                    TutorialNavigationView()
                        .transition(.asymmetric(insertion: .opacity, removal: .scale))
                        .animation(.spring(), value: appAppeared)
                        .onAppear {
                            Task(priority: .background) {
                                let firstTutorial = db.db.tutorials.needPresenting(after: nil)
                                await MainActor.run {
                                    withAnimation(defaultAnimation) {
            #warning("remove test, set to from db")
                                        appService.tutorialManager.type = firstTutorial
                                    }

                                    if firstTutorial == nil {
                                        appService.tutorialManager.needTutorial = false
                                    }
                                }
                            }
                        }
                        .onChange(of: appService.tutorialManager.type) { newValue in
                            if newValue == nil {
                                print("servicenil")
                                withAnimation(defaultAnimation) {
                                    appService.tutorialManager.frame = .zero
                                }
                                DispatchQueue.main
                                    .asyncAfter(deadline: .now() + .milliseconds(Int(self.animationDuration * 100)), execute: {
                                    Task(priority: .background) {
                                        if let currentService {
                                            let type = db.db.tutorials.complete(currentService)
                                            if let value = db.db.tutorials.needPresenting(after: currentService) {
                                                print(value, " yregfwedsax ")
                                                await MainActor.run {
                                                    withAnimation(self.defaultAnimation) {
                                                        appService.tutorialManager.type = type
                                                    }
                                                }
                                            } else {
                                                appService.tutorialManager.needTutorial = false
                                            }
                                        }

                                    }
                                })

                            } else {
                                currentService = newValue
                            }
                        }
                        .opacity(appService.tutorialManager.type == nil ? 0 : 1)
                        .animation(.smooth, value: appService.tutorialManager.type == nil)
                }

            }
    }
}

protocol TutorialModifierUIService { }

extension ViewModifier  where Self: TutorialModifierUIService {
    var defaultAnimation: Animation {
        .bouncy(duration: 0.4)
    }
    
    var animationDuration: CGFloat { 0.4 }
}
