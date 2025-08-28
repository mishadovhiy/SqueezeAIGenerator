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

    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("restart tutorial") {
                db.db.tutorials = .init()
                appService.tutorialManager = .init()
            }
        }
    }
}
