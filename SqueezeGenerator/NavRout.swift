//
//  NavRout.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import Foundation
import SwiftUI

enum NavRout: Hashable {
    case result
    case question(NetworkResponse.AdviceResponse.QuestionResponse)
    case requestToGenerateParameters(NetworkRequest.SqueezeRequest, NetworkResponse.CategoriesResponse.Categories?)
    case requestGenerated
    case empty
    case cardView(CardsViewModel.ViewProperties)
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

    @ViewBuilder
func bodyContent(
    _ viewModel: HomeViewModel,
    selectedRequest: Binding <NetworkRequest.SqueezeRequest?>,
    db: AppData) -> some View {
        switch self {
        case .resultResponse(let response):
            ResultView(saveModel: response)
        case .question(let response):
            SqueezeView(response: response)
        case .result:
            EmptyView()
//            ResultView(saveModel: viewModel.response ?? .init(response: .init(data: .init()), save: .init(date: .init())), savePressed: .init(get: {
//                false
//            }, set: {
//                if $0 {
//                    viewModel.savePressed(db: db)
//                }
//            }))
        case .requestToGenerateParameters(let request, let category):
            RequestParametersView(request: selectedRequest, selectedCategory: category)
            //{
//                withAnimation {
//                    viewModel.navValues.append(.empty)
//                    viewModel.selectedRequest = request
//                    viewModel.startGenerationRequest()
//                }
//            }
        case .requestGenerated:
            ReadyView(cancelPressed:{
                withAnimation {
                    viewModel.navValues.removeAll()
                    viewModel.rqStarted = false
                }
            })
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
            CardsView(properties) { selection in
                let questions = viewModel.response?.response.questions ?? []
                viewModel.response?.save = .init(date: .init(), category: viewModel.category, request: viewModel.selectedRequest, questionResults: [:])
                selection.forEach { (key: UUID, value: String) in
                    print("rtgerfwde key: ", key, " value: ", value)
                    if let question = questions.first(where: {
                        $0.id == key
                    }) {
                        if let options = question.options.first(where: {
                            $0.id == .init(uuidString: value)!
                        }) {
                            viewModel.response?.save.questionResults.updateValue(options, forKey: question)
                        } else {
                            fatalError()
                        }

                    } else {
                        fatalError()
                    }

                }
                DispatchQueue.main.async {
                    viewModel.savePressed(db: db)
                }
            }
        case .dbDetail(let data):
            DBDetailView(item: data)
        }
    }


    @ViewBuilder
    func body(
        _ viewModel: HomeViewModel,
        selectedRequest: Binding <NetworkRequest.SqueezeRequest?>,
        db: AppData) -> some View {
            bodyContent(viewModel, selectedRequest: selectedRequest, db: db)
                .background {
                    ClearBackgroundView()
                }
    }
}
