//
//  ResultView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct ResultView: View {
    @Binding var savePressed: Bool
    
    var body: some View {
        Button("save", action: {
            savePressed = true
        })
    }
}
