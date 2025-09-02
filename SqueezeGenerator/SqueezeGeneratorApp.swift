//
//  SqueezeGeneratorApp.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 14.07.2025.
//

import SwiftUI
import Combine
import UIKit

@main
struct SqueezeGeneratorApp: App {
    #warning("move to app service: test changes")
    @StateObject var db: LocalDataBaseManager = .init()
    @StateObject var appServices: AppServiceManager = .init()
    @State var appDataLoaded: Bool = false
#warning("todo: move to ServiceManager, @enviroment no combine")
    static var adPresenting = PassthroughSubject<Bool, Never>()
    static func triggerAdPresenting(with newValue: Bool = false) {
        adPresenting.send(newValue)
    }

    #warning("move to app service")
    fileprivate static var navigationHeight = PassthroughSubject<CGFloat, Never>()
    static func navigationHeight(with newValue: CGFloat = .zero) {
        navigationHeight.send(newValue)
    }

    init() {
        configureNavigationBar()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(appDataLoaded: $appDataLoaded)
                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
                .modifier(
                    TutorialPresenterModifier(appDataLoaded: appDataLoaded)
                )
                .modifier(
                    AlertModifier()
                )
                .environmentObject(db)
                .environmentObject(appServices)
                .onAppear {
                    setupObservers()
                }
        }
    }
    
    func setupObservers() {
        SqueezeGeneratorApp.adPresenting.sink { newValue in
            self.db.adPresenting = newValue
        }.store(in: &db.adPresentingValue)

        SqueezeGeneratorApp.navigationHeight.sink { newValue in
            self.db.navHeight = newValue
        }.store(in: &db.navHeightValue)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
