//
//  ResultView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct ResultView: View {
    let saveModel: AdviceQuestionModel
    let response: NetworkResponse.ResultResponse
    @Binding var savePressed: Bool
    
    var body: some View {
        VStack(content: {
            ScrollView(.vertical) {
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
    //                response
                }
            }
            Button {
                savePressed = true
            } label: {
                Text("Home")
            }

        })
        .navigationTitle(saveModel.save.request?.type ?? "")
        .onAppear {
            print(response.data, " erfwdas ")
        }
    }

//    @ViewBuilder
//    var response: some View {
//        ForEach(response.data, id: \.self) {
//            Text($0.key.rawValue)
//            Text($0.value)
//        }
//    }

}
