//
//  CollectionData.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 10.08.2025.
//

import UIKit

extension CollectionViewController {
    struct CollectionData: Hashable, Equatable {
        let title: String
        var description: String? = nil
        var cellBackground: UIColor? = nil
        var isSelected: Bool = false
        var id: String = UUID().uuidString
        var parentID: String = ""
        var isType: Bool = false
        var extraSmall: Bool = false

        var fontSize: CGFloat {
            extraSmall ? 12 : (isType ? 15 : 19)
        }

        var fontWeight: UIFont.Weight {
            isType ? .semibold : .black
        }
    }
}
