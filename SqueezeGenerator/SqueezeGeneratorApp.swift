//
//  SqueezeGeneratorApp.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 14.07.2025.
//

import SwiftUI

@main
struct SqueezeGeneratorApp: App {
    @StateObject var db: AppData = .init()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(db)
        }
    }
}
