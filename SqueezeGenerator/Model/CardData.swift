//
//  CardData.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import UIKit

struct CardData: Hashable, Equatable {
    static func == (lhs: CardData, rhs: CardData) -> Bool {
        ![
            lhs.title == rhs.title,
            lhs.description == rhs.description,
            lhs.color == rhs.color,
            lhs.id == rhs.id,
            lhs.buttons == rhs.buttons
        ].contains(false)
    }
    
    let title: String
    let description: String
    var color: UIColor = .random
    var id: UUID = .init()
    var rotation: CGFloat = [10, -10, -15, 15, 9, 12, -13, -12].randomElement() ?? 0
    let buttons: [CollectionViewController.CollectionData]
}

extension [CardData] {
    static let demo: Self = [
        .init(title: "Phihopasy", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Phihopasy Phihopasy Phihopasy Phihopasy Phihopasy ", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Will Generate questions on: deep, obvious symptoms that strongly represents illness", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Will Generate questions on: deep, obvious symptoms that strongly represents illness Will Generate questions on: deep, obvious symptoms that strongly represents illness", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Phihopasy", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Phihopasy", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo)
    ]
}
