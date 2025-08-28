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
            field(title: "Header", text: $request.header)
            field(title: "Title", text: $request.title)
            field(title: "Message", text: $request.text, placeholder: "Having an issue or want to give an advice?")
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

            }
        }
        .navigationTitle("Support Request")
        .navigationBarTitleDisplayMode(.large)
    }

    func field(title: String, text: Binding<String>, placeholder: String = "") -> some View {
        VStack {
            Text(title)
            TextField("", text: text, prompt: Text(placeholder))
        }
    }
}
