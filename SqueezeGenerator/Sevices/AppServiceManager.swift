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
}

struct AlertManager {
    private var messageHolder: [AlertContentModel] = []

    var currentMessage: AlertContentModel? {
        messageHolder.first
    }

    mutating func dismiss() {
        print(messageHolder.count, " rtegrfwdsa ")
        if messageHolder.isEmpty {
            return
        }
        messageHolder.removeLast()
    }

    mutating func present(_ message: AlertContentModel) {
        messageHolder.append(message)
    }


}

struct AlertContentModel {
    let title: String
    let description: String
    let imageName: ImageResource?
    let buttons: [Button]
    let id: UUID

    init(title: String,
         description: String = "",
         imageName: ImageResource? = nil,
         buttons: [Button] = []
    ) {
        self.title = title
        self.description = description
        self.imageName = imageName
        if buttons.isEmpty {
            self.buttons = [.init(title: "Close")]
        } else {
            self.buttons = buttons
        }
        self.id = .init()
    }

    struct Button {
        let title: String
        let pressed: (()->())?

        init(title: String,
             pressed: (() -> Void)? = nil) {
            self.title = title
            self.pressed = pressed
        }
    }
}
