//
//  RequestParametersView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 23.07.2025.
//

import SwiftUI

struct RequestParametersView: View {
    let request: NetworkRequest.SqueezeRequest
    let okPressed: (NetworkRequest.SqueezeRequest) -> ()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("ok") {
            okPressed(request)
        }
    }
}

struct ReadyView: View {
    let cancelPressed: () -> ()
    var body: some View {
        Text("ready")
        Button("cancel") {
            cancelPressed()
        }
    }
}
