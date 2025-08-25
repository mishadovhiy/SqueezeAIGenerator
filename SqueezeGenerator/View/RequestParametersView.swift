//
//  RequestParametersView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 23.07.2025.
//

import SwiftUI

struct RequestParametersView: View {
#warning("refactor: replace 'request' with 'selectedCategory'")
    @Binding var request: NetworkRequest.SqueezeRequest?

    var selectedCategory:  NetworkResponse.CategoriesResponse.Categories?
    @State var statPresenting: Bool = false
    @EnvironmentObject private var db: AppData
    var dbResponses: [AdviceQuestionModel]? {
        db.db.responses.filter( {
           $0.save.request?.type == request?.type
       })
    }

    var body: some View {
        VStack() {
            Spacer()
                .frame(height: 40)
            cardView
            Spacer()
                .frame(height: 40)
//                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 30)
        .navigationTitle(request?.parentCategory.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                if let dbResponses, !dbResponses.isEmpty {
                    toolBar(dbResponses)
                }
            }
        }
        .fullScreenCover(isPresented: $statPresenting) {
            DBCategoriyNavView(selectedType: request?.type ?? "")
        }
        .onChange(of: statPresenting) { newValue in
            db.sheetPresenting = newValue
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    func toolBar(_ savedResponses: [AdviceQuestionModel]?) -> some View {
        Button {
            statPresenting = true
        } label: {
            Image(.chart)
                .resizable()
                .scaledToFit()
                .shadow(radius: 5)
                .background {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(savedResponses?.count ?? 0)")
                                .foregroundColor(.init(uiColor: textColor))
                                .font(.system(size: 7))
                                .padding(2)
                                .background(Color(uiColor: tint))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                }
        }
        .padding(.trailing, 9)
        .frame(width: .Padding.smallButtonSize.rawValue, height: .Padding.smallButtonSize.rawValue)
        .blurBackground(cornerRadius: .CornerRadius.button.rawValue)
    }

    var cardView: some View {
        VStack {
            scrollContentView
            difficultiesView
        }
        .blurBackground()
        .cornerRadius(32)
    }

    var typeTitle: some View {
        Text(request?.type.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
            .font(.system(size: 32, weight: .semibold))
            .frame(alignment: .center)
            .multilineTextAlignment(.center)
            .background {
                HStack {
                    Spacer()
                    VStack {
                        Text(request?.category.addSpaceBeforeCapitalizedLetters.capitalized ?? "")
                            .foregroundColor(.init(uiColor: textColor))
                            .lineLimit(1)
                            .font(.system(size: 9, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: tint))
                            .cornerRadius(6)
                            .offset(x: -4, y: -13)
                            .shadow(color: .black.opacity(0.2),
                                    radius: 4)
                        Spacer()
                    }
                }
            }
    }

    var scrollContentView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 15) {
                Spacer().frame(height: 20)
                categoryImage
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        typeTitle
                        Spacer()
                    }
                }

                Text(description)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
        }
    }

    var difficultiesView: some View {
        HStack(content: {
            difficutiesPicker
            Spacer()
                .frame(maxWidth: request?.difficulty == nil ? .infinity : .zero)
                .animation(.bouncy(duration: 0.3), value: request?.difficulty)

        })
        .padding(.horizontal, 5)
        .frame(alignment: .leading)
        .padding(.bottom, 0)
        .animation(.bouncy(duration: 0.5), value: request?.difficulty)
        .padding(.bottom, 14)
        .padding(.horizontal, 10)
    }

    var categoryImage: some View {
        HStack {
            Spacer()
            AsyncImage(url: .init(string: selectedCategory?.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(.circular)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                default:
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.red)
                        .frame(width: 60)
                }
            }
            .padding(25)
            .blurBackground()
            .cornerRadius(100)
            Spacer()
        }

    }

    var textColor: UIColor {
        tint.isLight ? .black : .white
    }
    var tint: UIColor {
        .init(hex: selectedCategory?.color?.topLeft ?? "") ?? .dark
    }

    var difficutiesPicker: some View {
        ForEach(NetworkRequest.SqueezeRequest.Difficulty.allCases,
                id:\.rawValue) { difficulty in
            Button {
                withAnimation(.smooth) {
                    if request?.difficulty == difficulty {
                        request?.difficulty = nil
                    } else {
                        request?.difficulty = difficulty
                    }
                }
            } label: {
                Text(difficulty.rawValue.capitalized)
                    .lineLimit(1)
                    .padding(.horizontal, request?.difficulty == difficulty ? .zero : 15)
                    .animation(.bouncy(duration: 0.5), value: request?.difficulty)
            }
            .foregroundColor(.init(uiColor: request?.difficulty == difficulty ? textColor : .white))
            .tint(request?.difficulty == difficulty ? .white : .white)
            .font(.system(size: 14, weight: .regular))
            .frame(height: 35)
            .frame(maxWidth: request?.difficulty == difficulty ? .infinity : .none)
            .background(content: {
                request?.difficulty == difficulty ? Color(uiColor: tint) : .white.opacity(0.1)

            })
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white, lineWidth: request?.difficulty == difficulty ? 0 : 1)
            }
            .shadow(color: .black.opacity(0.3), radius: 10)
            .animation(.smooth, value: request?.difficulty == difficulty)

        }
    }

    var description: AttributedString {
        let text = NSMutableAttributedString()
        
        text.append(.init(string: "Will Generate questions", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ]))
        text.append(.init(string: " on" + (request?.description ?? ""), attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
        ]))
        return .init(text)
    }
}

struct ReadyView: View {
    let presenter: Presenter

    var body: some View {
        Text("ready")
        Button("cancel") {
            presenter.cancelPressed()
        }
    }
}
extension ReadyView {
    struct Presenter: Equatable, Hashable {
        let cancelPressed: ()->()
        let id: UUID

        init(cancelPressed: @escaping () -> Void) {
            self.cancelPressed = cancelPressed
            self.id = .init()
        }
        static func == (lhs: Presenter, rhs: Presenter) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

    }
}
