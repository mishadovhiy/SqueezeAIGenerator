//
//  SupportView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 28.08.2025.
//

import SwiftUI

struct SupportView: View {
    
    @EnvironmentObject var appService: AppServiceManager
    @Environment(\.dismiss) var dismiss
    
    @State private var request: NetworkRequest.SupportRequest = .init()
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(
                    columns: [.init()],
                    pinnedViews: .sectionFooters) {
                        Section {
                            Spacer().frame(height: 30)
                            section
                        } footer: {
                            doneButton
                        }
                    }
            }
            .scrollDismissesKeyboard(.interactively)
            Spacer()
        }
        .padding(.horizontal, 10)
        .navigationTitle("Support Request")
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .modifier(NavigationBackgroundModifier())
    }
    
    private var section: some View {
        VStack(spacing: 15) {
            field(title: "Header", text: $request.header, placeholder: "Your title", needDivider: false, errorText: request.error[.header])
            field(title: "Title", text: $request.title, placeholder: "Subject of the message", errorText: request.error[.title])
            field(title: "Message", text: $request.text, placeholder: "Having an issue or want to give an advice?", isLarge: true, errorText: request.error[.text])
        }
        .padding(10)
        .blurBackground()
    }
    
    private var doneButton: some View {
        HStack {
            Spacer().frame(maxWidth: .infinity)
            Button {
                sendPressed()
            } label: {
                Text("Send")
            }
            .font(.system(size: 14, weight: .medium))
            .tint(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .blurBackground()
        }
    }
        
    @ViewBuilder
    private func fieldTitle(
        _ title: String,
        _ needDivider: Bool = true
    ) -> some View {
        if needDivider {
            Divider()
        }
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white.opacity(0.5))
            .padding(.leading, 10)
    }
    
    private func field(title: String,
               text: Binding<String>,
               placeholder: String = "",
               isLarge: Bool = false,
               needDivider: Bool = true,
               errorText: String?) -> some View {
        VStack(alignment: .leading) {
            fieldTitle(title, needDivider)
            
            textFieldView(text: text, placeholder: placeholder, isLarge: isLarge, errorText: errorText)
            
            if let errorText {
                errorTitle(errorText)
            }
        }
        .onChange(of: text) { newValue in
            withAnimation {
                self.request.error.removeAll()
            }
        }
    }
    
    private func errorTitle(_ title: String) -> some View {
        Text(title)
            .foregroundColor(.red)
            .animation(.smooth, value: title)
            .transition(.move(edge: .bottom))
            .padding(.leading, 10)
    }
    
    @ViewBuilder
    private func textFieldView(
        text: Binding<String>,
        placeholder: String = "",
        isLarge: Bool = false,
        errorText: String?
    ) -> some View {
        if !isLarge {
            textField(text, placeholder: placeholder, errorText: errorText)
        } else {
            ZStack {
                textEditor(text, placeholder: placeholder, errorText: errorText)
                if !placeholder.isEmpty && text.wrappedValue.isEmpty {
                    textEditorPlaceholder(placeholder)
                }
            }
            .frame(minHeight: 70, maxHeight: 140)
        }
    }
    
    private func textField(
        _ text: Binding<String>,
        placeholder: String,
        errorText: String?
    ) -> some View {
        TextField("",
                  text: text,
                  prompt:
                    placeHolder(placeholder)
        )
        .frame(height: 40)
        .padding(.horizontal, 10)
        .blurBackground(color: errorText != nil ? .red : nil)
        .animation(.smooth, value: errorText)
    }
    
    private func textEditor(
        _ text: Binding<String>,
        placeholder: String,
        errorText: String?
    ) -> some View {
        TextEditor(text: text)
            .frame(maxHeight: 140)
            .background(.clear)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 6)
            .blurBackground(color: errorText != nil ? .red : nil)
            .animation(.smooth, value: errorText)
    }
    
    private func placeHolder(_ text: String) -> Text {
        Text(text)
            .foregroundColor(.white.opacity(0.3))
            .font(.system(size: 11, weight: .semibold))
    }
    
    private func textEditorPlaceholder(_ text: String) -> some View {
        VStack(alignment: .leading) {
            placeHolder(text)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    
    private func sendPressed() {
        request.validate()
        if !request.error.isEmpty {
            return
        }
        isLoading = true
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
        Task(priority: .background) {
            NetworkModel().support(request) { response in
                isLoading = false
                if response?.success ?? false {
                    dismiss()
                    appService.alertManager.present(.init(title:  "Success", description: "Support Request have been sent", imageName: .supportSuccess))
                } else {
                    appService.alertManager.present(.init(title:  "Errror", description: "Error sending support request", imageName: .supportError))
                }
                
            }
        }
    }

}
