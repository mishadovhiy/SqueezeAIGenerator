//
//  TutorialManager.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 27.08.2025.
//

import Foundation

struct TutorialManager {
    var type: DataBase.Tutorial.TutorialType? = nil
    var frame: CGRect = .zero
    var completedSqueezeTypeID: String?
    var needTutorial: Bool = true
    // sets nil to a type if they are matching
    /// - when nil did set, type is changed to the next, unsaved type, from .allCases
    mutating func removeTypeWhenMatching(_ type: DataBase.Tutorial.TutorialType...) {
        guard let currentType = self.type else {
            return
        }
        if type.contains(currentType) {
            self.type = nil
        }
    }
}
