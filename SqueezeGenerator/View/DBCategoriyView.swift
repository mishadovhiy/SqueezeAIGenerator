//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct DBCategoriyView: View {
    
    @EnvironmentObject private var db: AppData
    let selectedCategory: String
    let selectedType: String
    private var data: [AdviceQuestionModel] {
        db.db.responses.filter({
            $0.save.request?.type == selectedType
        })
    }
    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews:[.sectionHeaders], content: {
                Section {
                    VStack {
                        if data.isEmpty {
                            Text("no saved data")
                        }
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
                                            Text(response.save.request?.difficulty.rawValue ?? "")
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
                    .background {
                        Color.black.opacity(0.12)
                            .blur(radius: 50)
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
}
