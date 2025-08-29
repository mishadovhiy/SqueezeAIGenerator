//
//  AlertView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 29.08.2025.
//

import SwiftUI

struct AlertView: View {

    let data: AlertContentModel
    let dismiss: ()->()

    var body: some View {
        ZStack {
            BlurView()
            VStack {
                Text(data.title)
                Text(data.description)
                Button {
                    dismiss()
                } label: {
                    Text("close")
                }
            }
        }
        .zIndex(99999)
    }
}
