//
//  ResultView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct ResultView: View {
    let saveModel: AdviceQuestionModel
    let canScroll: Bool

    init(saveModel: AdviceQuestionModel, canScroll: Bool = true) {
        self.saveModel = saveModel
        self.canScroll = canScroll
    }

    var body: some View {
        if canScroll {
            ScrollView(
                .vertical,
                showsIndicators: false)
            {
                contentView
            }
            .padding(.horizontal, 10)
        } else {
            contentView
        }
    }

    @ViewBuilder
    var contentHeader: some View {
        Spacer().frame(height: 40)
        CircularProgressView(progress: saveModel.resultPercent)
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
    }

    var contentView: some View {
        VStack {

            if canScroll {
                contentHeader
            }

            VStack(spacing: 10) {
                responseView
            }
            .padding(10)
            .blurBackground()
        }
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
                .background(.white.opacity(.Opacity.separetor.rawValue))
        }
    }

}
