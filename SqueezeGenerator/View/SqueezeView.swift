//
//  SqueezeView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct SqueezeView: View, Hashable {
    let response: NetworkResponse.AdviceResponse.QuestionResponse
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(response.questionName)
                Text(response.description)
                    .opacity(0.5)
            }
            Spacer()
        }
        .onAppear {
            print(response.questionName, " uyhtyrgtefrd ")
        }
    }
}
