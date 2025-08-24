//
//  NavRout.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import Foundation
import SwiftUI

enum NavigationRout: Hashable {
    case result
    case question(NetworkResponse.AdviceResponse.QuestionResponse)
    case requestToGenerateParameters(Binding<NetworkRequest.SqueezeRequest?>, NetworkResponse.CategoriesResponse.Categories?)
    case requestGenerated(ReadyView.Presenter)
    case empty
    case cardView(CardsView.Presenter)
    case resultResponse(AdviceQuestionModel)

    case dbDetail(AdviceQuestionModel)

    var needDoneButton: Bool {
        switch self {
        case .requestToGenerateParameters,
                .requestGenerated, .requestToGenerateParameters
            :
            true
        default:
            false
        }
    }

    var illustrationScale: CGFloat {
        switch self {
            //        case .requestToGenerateParameters:
            //            0
        default: 0
        }
    }
#warning("remove _ requestt: Binding<NetworkRequest.SqueezeRequest?> to case:")
    @ViewBuilder
    func bodyContent(_ requestt: Binding<NetworkRequest.SqueezeRequest?>) -> some View {
        switch self {
        case .resultResponse(let response):
            ResultView(saveModel: response)

        case .question(let response):
            SqueezeView(response: response)

        case .result:
            EmptyView()

        case .requestToGenerateParameters(let request, let category):
            RequestParametersView(request: requestt, selectedCategory: category)

        case .requestGenerated(let presenter):
            ReadyView(presenter: presenter)

        case .empty:
            VStack(content: {
                Spacer()
                    .frame(maxHeight: .infinity)
                Spacer()
                    .frame(maxHeight: .infinity)
                Text("Generating")
                    .font(.Type.section.font)
                    .opacity(.Opacity.descriptionLight.rawValue)
                Spacer()
                    .frame(maxHeight: .infinity)
            })
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()

        case .cardView(let properties):
            CardsView(properties)

        case .dbDetail(let data):
            DBDetailView(item: data)
        }
    }


    @ViewBuilder
    func body(_ request: Binding<NetworkRequest.SqueezeRequest?>) -> some View {
        bodyContent(request)
            .background {
                ClearBackgroundView()
            }
    }
}
#warning("case not updating")
extension Binding: Equatable where Value: Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Binding: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
