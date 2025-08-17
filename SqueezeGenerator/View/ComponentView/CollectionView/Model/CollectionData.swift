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
        var percent: String? = nil
        var label: String? = nil
        var isType: Bool = false
        var extraSmall: Bool = false
        var imageURL: String = "\(Keys.apiBaseURL.rawValue)/generateSqueeze/icons/depression.png"
        var fontSize: CGFloat {
            extraSmall ? 11 : (isType ? 11 : 13)
        }

        var fontWeight: UIFont.Weight {
            isType ? .semibold : .semibold
        }
    }
}
