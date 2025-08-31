//
//  AlertContentModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

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
        self.id = UUID.init()
        print(id, " yhgtfrdes ")
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
