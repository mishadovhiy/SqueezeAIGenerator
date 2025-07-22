//
//  TextView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct TextView: View {
    let text: String
    let needScroll: Bool
    
    var body: some View {
        if needScroll {
            ScrollView(.vertical) {
                Text(text)
            }
        } else {
            Text(text)
        }
    }
}
