//
//  RequestParametersView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 23.07.2025.
//

import SwiftUI

struct RequestParametersView: View {
    @Binding var request: NetworkRequest.SqueezeRequest?
    @State var statPresenting: Bool = false
    @EnvironmentObject private var db: AppData

    var body: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 15) {
                Text(title)
                Text(description)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            Spacer()
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

//                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 30)
        .navigationTitle(request?.type ?? "")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                if db.db.responses.last(where: {
                    $0.save.request?.type == request?.type
                }) != nil {
                    Button {
                        statPresenting = true
                    } label: {
                        Image(.score)
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(.trailing, 9)
                    .frame(width: .Padding.smallButtonSize.rawValue, height: .Padding.smallButtonSize.rawValue)
                    .blurBackground(cornerRadius: .CornerRadius.button.rawValue)

                }
                
            }
        }
        .fullScreenCover(isPresented: $statPresenting) {
            DBCategoriyNavView(selectedType: request?.type ?? "")
        }
        .onChange(of: statPresenting) { newValue in
            db.sheetPresenting = newValue
        }
        .navigationBarTitleDisplayMode(.large)

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
                Text(difficulty.rawValue)
                    .lineLimit(1)
                    .padding(.horizontal, request?.difficulty == difficulty ? .zero : 15)
                    .animation(.bouncy(duration: 0.5), value: request?.difficulty)
            }
            .foregroundColor(request?.difficulty == difficulty ? .dark : .white)
            .tint(request?.difficulty == difficulty ? .white : .white)
            .font(.system(size: 16, weight: .semibold))
            .frame(height: 40)
            .frame(maxWidth: request?.difficulty == difficulty ? .infinity : .none)
            .background(request?.difficulty == difficulty ? .white : .black.opacity(0.15))
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white, lineWidth: 2)
            }
            .shadow(color: .black, radius: 10)
            .animation(.smooth, value: request?.difficulty == difficulty)

        }
    }
    
    var title: AttributedString {
        let text = NSMutableAttributedString()
        text.append(.init(string: request?.category ?? "", attributes: [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]))
        text.append(.init(string: " " + "Squeeze", attributes: [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]))
        return .init(text)
    }
    var description: AttributedString {
        let text = NSMutableAttributedString()
        
        text.append(.init(string: "Will Generate questions", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]))
        text.append(.init(string: " on" + (request?.description ?? ""), attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
        ]))
        return .init(text)
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
