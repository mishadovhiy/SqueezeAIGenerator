//
//  HapticService.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 02.09.2025.
//

import UIKit

struct HapticService {

    func play(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
