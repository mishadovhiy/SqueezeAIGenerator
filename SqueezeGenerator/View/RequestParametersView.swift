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
            difficutiesPicker
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
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
                            .padding(8)
                    }
                    .frame(width: .Padding.smallButtonSize.rawValue, height: .Padding.smallButtonSize.rawValue)
                }
                
            }
        }
        .fullScreenCover(isPresented: $statPresenting) {
            DBCategoriyNavView(selectedType: request?.type ?? "")
        }
        .onChange(of: statPresenting) { newValue in
            db.sheetPresenting = newValue
        }
    }

    var difficutiesPicker: some View {
        ForEach(NetworkRequest.SqueezeRequest.Difficulty.allCases,
                id:\.rawValue) { difficulty in
            Button(difficulty.rawValue) {
                withAnimation(.smooth) {
                    if request?.difficulty == difficulty {
                        request?.difficulty = nil
                    } else {
                        request?.difficulty = difficulty
                    }
                }
                
            }
            .foregroundColor(request?.difficulty == difficulty ? .dark : .yellow)
            .tint(request?.difficulty == difficulty ? .white : .white)
            .font(.system(size: 17, weight: .semibold))
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(request?.difficulty == difficulty ? .yellow : .black.opacity(0.15))
            .cornerRadius(30)
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.white, lineWidth: 2)
            }
            .shadow(color: .black, radius: 10)
            .animation(.smooth, value: request?.difficulty == difficulty)

        }
    }
    
    var title: AttributedString {
        let text = NSMutableAttributedString()
        text.append(.init(string: request?.category ?? "", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold)
        ]))
        text.append(.init(string: " " + "Squeeze", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular)
        ]))
        return .init(text)
    }
    var description: AttributedString {
        let text = NSMutableAttributedString()
        
        text.append(.init(string: "Will Generate questions", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular)
        ]))
        text.append(.init(string: " on" + (request?.description ?? ""), attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
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
