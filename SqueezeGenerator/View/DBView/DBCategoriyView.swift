//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI


struct DBCategoriyNavView: View {
    @EnvironmentObject private var db: AppData
    @Environment(\.dismiss) private var dismiss

    let selectedType: String
    
    var body: some View {
        VStack(spacing: 0) {
//            HStack(content: {
//                Button("close") {
//                    dismiss.callAsFunction()
//                }
//            })
//            .frame(height: 44)
//            .frame(maxWidth: .infinity)
//            .background(.black)
//            LinearGradient(colors: [
//                .black, .clear
//            ],
//                           startPoint: .top,
//                           endPoint: .bottom)
//            .frame(height: 40)
            NavigationStack(root: {
                DBCategoriyView(selectedCategory: db.db.responses.first(where: {$0.save.request?.type == selectedType})?.save.category ?? "", selectedType: selectedType)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button("close") {
                                dismiss.callAsFunction()
                            }
                        }
                    }
            })
            .padding(.top, -40)
            .background {
                VStack(spacing: 0) {
                    HStack(content: {
                    })
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    LinearGradient(colors: [
                        .black, .clear
                    ],
                                   startPoint: .top,
                                   endPoint: .bottom)
                    .frame(height: 40)
                    Spacer()
                }
            }

        }
        .background {
            ClearBackgroundView()
        }
    }
}

struct DBCategoriyView: View {
    
    @EnvironmentObject private var db: AppData
    let selectedCategory: String
    let selectedType: String
    
    var body: some View {
        ScrollView {
            Color.clear
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.frame(in: .global)) { newValue in
                                print(newValue, " rerfwedas ")
                            }
                    }
                }
                .frame(height: 0)
            LazyVStack(pinnedViews:[.sectionHeaders], content: {
                Text(selectedType)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)

                Section {
                    VStack {
                        if data.isEmpty {
                            Text("no saved data")
                        }
                        listView
                    }
                    .background {
                        Color.black.opacity(0.12)
                            .overlay(content: {
                                BlurView()
                            })
                            .cornerRadius(12)
                            
                    }
                } header: {
                    HStack {
                        Text("Date")
                        Spacer()
                        HStack {
                            Text("Score")
                            Text("Difficulty")
                        }
                    }
                    .opacity(0.5)
                    .padding(.horizontal, 20)
                }

            })
            .padding(.horizontal, 10)
        }
        .background {
            ClearBackgroundView()
        }
        .navigationTitle(selectedCategory)
    }
    
    var listView: some View {
        ForEach(data, id: \.id) { response in
            NavigationLink {
                DBDetailView(item: response)
            } label: {
                VStack {
                    HStack {
                        Text(response.save.date.stringDate)

                        Spacer()
                        HStack {
                            Text("\(Int(response.resultPercent * 100))%")
                            Text(response.save.request?.difficulty?.rawValue ?? "")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .tint(.white)
            }
            Divider()
        }
    }
    
    private var data: [AdviceQuestionModel] {
        db.db.responses.filter({
            $0.save.request?.type == selectedType
        })
    }
}
