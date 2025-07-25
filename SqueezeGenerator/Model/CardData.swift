//
//  CardData.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import UIKit

struct CardData {
    let title: String
    let description: String
    let color: UIColor
    var id: UUID = .init()
    var rotation: CGFloat = [20, -20, -40, 40, 30, 35, -35, -30].randomElement() ?? 0
    let buttons: [CollectionViewController.CollectionData]
}

extension [CardData] {
    static let demo: Self = [
        .init(title: "Phihopasy", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Phihopasy", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Phihopasy", description: """
            Will Generate questions on: deep, obvious symptoms that strongly represents illness
            """, color: .random, buttons: .demo),
        .init(title: "Phihopasy", description: """
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
