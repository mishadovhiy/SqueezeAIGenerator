//
//  AppServiceManager.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import SwiftUI

class AppServiceManager: ObservableObject {
    @Published var tutorialManager: TutorialManager = .init()
    @Published var alertManager: AlertManager = .init()
    let haptic: HapticService = .init()
}
