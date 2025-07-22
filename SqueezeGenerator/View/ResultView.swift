//
//  ResultView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct ResultView: View, Hashable, Equatable {
    static func == (lhs: ResultView, rhs: ResultView) -> Bool {
        // Comparing the state that matters for equality
        return lhs.savePressed == rhs.savePressed
    }
    
    // Hashing function
    func hash(into hasher: inout Hasher) {
        // Hash the properties that define uniqueness
        hasher.combine(savePressed)
    }
    
    
    @Binding var savePressed: Bool
    var body: some View {
        Button("save", action: {
            savePressed = true
        })
    }
}
