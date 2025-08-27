//
//  TutorialModifier.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

struct TutorialModifier: ViewModifier {
    @EnvironmentObject var appService: AppServiceManager
    @EnvironmentObject var db: LocalDataBaseManager
    @State var appAppeared: Bool = false
    @State private var currentService: DataBase.Tutorial.TutorialType?
    func body(content: Content) -> some View {
        content
            .overlay {
                TutorialNavigationView()
                    .transition(.asymmetric(insertion: .opacity, removal: .scale))
                    .animation(.spring(), value: appAppeared)
                    .onAppear {
                        appService.tutorialManager.current = .selectParentCategory
                    }
                    .onChange(of: appService.tutorialManager.current) { newValue in
                        if newValue == nil {
                            print("servicenil")
                            appService.tutorialManager.frame = .zero
                            Task(priority: .background) {
                                if let value = db.db.tutorials.needPresenting() {
                                    print(value, " yregfwedsax ")
                                    let type = db.db.tutorials.complete(currentService!)
                                    await MainActor.run {
                                        appService.tutorialManager.current = type
                                    }
                                }
                            }
                        } else {
                            currentService = newValue
                        }
                    }
            }
    }
}
