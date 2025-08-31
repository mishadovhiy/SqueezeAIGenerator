//
//  SupportView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 28.08.2025.
//

import SwiftUI

struct SupportView: View {
    @State var request: NetworkRequest.SupportRequest = .init()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            VStack {
                field(title: "Header", text: $request.header)
                field(title: "Title", text: $request.title)
                field(title: "Message", text: $request.text, placeholder: "Having an issue or want to give an advice?", isLarge: true)
            }
            .padding(10)
            .blurBackground()
            HStack {
                Spacer().frame(maxWidth: .infinity)
                Button {
                    Task(priority: .background) {
                        NetworkModel().support(request) { response in
                            print(response?.success, " rtgerfed ")
                            dismiss()
                        }
                    }
                } label: {
                    Text("Send")
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 8)
                .blurBackground()

            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .navigationTitle("Support Request")
        .navigationBarTitleDisplayMode(.large)
    }

    func field(title: String, text: Binding<String>, placeholder: String = "", isLarge: Bool = false) -> some View {
        VStack {
            Text(title)
            if !isLarge {
                TextField("", text: text, prompt: Text(placeholder))
                    .blurBackground()
            } else {
                TextEditor(text: text)
                    .overlay {
                        if !placeholder.isEmpty && text.wrappedValue.isEmpty {
                            VStack {
                                Text(placeholder)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity)
                                Spacer()
                                
                            }
                        }
                    }
                    .frame(maxHeight: 140)
            }
        }
    }
}
