//
//  ResultView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct ResultView: View {
    let saveModel: AdviceQuestionModel
    
    var body: some View {
        VStack(content: {
            ScrollView(.vertical) {
                VStack {
                    Spacer().frame(height: 40)
                    ZStack {
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 3)
                            Circle()
                                .trim(from: 0, to: saveModel.resultPercent)
                                .stroke(.red, lineWidth: 3)
                        }
                        .frame(width: 150)
                        VStack {
                            Text("Your score")
                                .font(.system(size: 9, weight: .semibold))
                                .opacity(0.4)
                            Text("\(saveModel.resultPercentInt)%")
                                .font(.system(size: 32, weight: .bold))
                        }
                    }
                    Spacer()
                        .frame(height: 40)
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(saveModel.save.request?.category.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.2))
                        Text("Category")
                            .font(.system(size: 9, weight: .regular))
                            .foregroundColor(.white.opacity(0.2))
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    VStack(spacing: 10) {
                        responseView
                    }
                    .padding(10)
                    .background {
                        BlurView()
                            .background {
                                Color.white.opacity(0.05)
                            }
                            .cornerRadius(24)
                    }
                }
            }
            .padding(.horizontal, 10)
        })
        .navigationTitle(saveModel.save.request?.type.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
    }

    @ViewBuilder
    var responseView: some View {
        ForEach(NetworkRequest.ResultRequest.ResponseStructure.allCases, id: \.key) { key in
            HStack(alignment: .top) {
                Text(key.key.addSpaceBeforeCapitalizedLetters.capitalized)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 70, alignment: .leading)
                Text(saveModel.save.aiResult?.data[key]?.replacingOccurrences(of: "\n", with: "") ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
        }
    }

}
