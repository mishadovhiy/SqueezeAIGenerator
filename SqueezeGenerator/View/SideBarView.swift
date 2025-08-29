//
//  SideBarView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.08.2025.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var db: LocalDataBaseManager
    @EnvironmentObject var appService: AppServiceManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Button("restart tutorial") {
                db.db.tutorials = .init()
                appService.tutorialManager = .init()
            }

            Button {
                navigationManager.append(.webview(.privacy))
            } label: {
                Text("Privacy policy")
            }

            Button {
                navigationManager.append(.support)
            } label: {
                Text("Support")
            }

            Button {
                let url = URL(string: "https://mishadovhiy.com")
                guard let url, UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url)
            } label: {
                Text("app website")
            }

        }
    }
}
