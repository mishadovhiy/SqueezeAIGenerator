//
//  ResultView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct ResultView: View {
    let saveModel: AdviceQuestionModel
    @Binding var savePressed: Bool
    
    var body: some View {
        VStack {
            VStack {
                Text(saveModel.save.request?.category ?? "")
                Spacer()
                    .frame(maxHeight: .infinity)
                VStack {
                    Text("Your score")
                        .font(.system(size: 11, weight: .semibold))
                        .opacity(0.4)
                    Text("\(saveModel.resultPercent * 100)%")
                }
                Spacer()
                    .frame(maxHeight: .infinity)
            }
            Button("save", action: {
                savePressed = true
            })
        }
        .navigationTitle(saveModel.save.request?.type ?? "")
    }
    
    
}
