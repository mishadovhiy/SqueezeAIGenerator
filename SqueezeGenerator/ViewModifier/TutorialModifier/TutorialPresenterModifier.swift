//
//  TutorialModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

///- waits for TutorialType to be setted to nil
struct TutorialPresenterModifier: ViewModifier, TutorialModifierUIService {
    
    @EnvironmentObject private var appService: AppServiceManager
    @EnvironmentObject private var db: LocalDataBaseManager
    @State private var appAppeared: Bool = false
    @State private var currentService: DataBase.Tutorial.TutorialType?
    let appDataLoaded: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if appService.tutorialManager.needTutorial {
                    TutorialNavigationView()
                        .transition(.asymmetric(insertion: .opacity, removal: .scale))
                        .animation(.spring(), value: appAppeared)
                        .onChange(of: appService.tutorialManager.type) { newValue in
                            appService.haptic.play()
                            if newValue == nil {
                                completeTutorial()
                            } else {
                                currentService = newValue
                            }
                        }
                        .opacity(appService.tutorialManager.type == nil ? 0 : 1)
                        .animation(.smooth, value: appService.tutorialManager.type == nil)
                }
            }
            .onChange(of: appDataLoaded) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    checkIfNeedTutorial()
                })
            }
    }
    
    func checkIfNeedTutorial() {
        Task(priority: .background) {
            let firstTutorial = db.db.tutorials.needPresenting(after: nil)
            await MainActor.run {
                withAnimation(defaultAnimation) {
                    appService.tutorialManager.type = firstTutorial
                }
                
                if firstTutorial == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        withAnimation(.smooth(duration: 3), {
                            appService.tutorialManager.needTutorial = false
                        })
                    })
                }
            }
        }
    }
    
    func completeTutorial() {
        print("completingegrfwda")
        withAnimation(defaultAnimation) {
            appService.tutorialManager.frame = .zero
        }
        DispatchQueue.main
            .asyncAfter(deadline: .now() + .milliseconds(Int(self.animationDuration * 100)), execute: {
                completedTutorialDB()
            })
    }
    
    func completedTutorialDB() {
        Task(priority: .background) {
            if let currentService {
                print("db completedd")

                let currentService = appService.tutorialManager.skipPressed ? DataBase.Tutorial.TutorialType.allCases.last! : currentService
                print(currentService, " tg4refwdas ")
                let type = db.db.tutorials.complete( currentService)
                if let value = db.db.tutorials.needPresenting(after: currentService) {
                    await MainActor.run {
                        withAnimation(self.defaultAnimation) {
                            appService.tutorialManager.type = type
                        }
                    }
                } else {
                    await MainActor.run() {
                        print("dont need tutorial")
                        appService.tutorialManager.needTutorial = false
                    }
                }
            }
        }
    }
}

protocol TutorialModifierUIService { }

extension ViewModifier  where Self: TutorialModifierUIService {
    var defaultAnimation: Animation {
        .smooth(duration: 0.4)
    }
    
    var animationDuration: CGFloat { 0.4 }
}
