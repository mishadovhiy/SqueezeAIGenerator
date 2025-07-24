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
    private var data: [AdviceQuestionModel] {
        db.db.responses.filter({
            $0.save.request?.category == selectedCategory
        })
    }
    var body: some View {
        ScrollView {
            VStack {
                if data.isEmpty {
                    Text("no saved data")
                }
                ForEach(data, id: \.id) { response in
                    NavigationLink {
                        DBDetailView(item: response)
                    } label: {
                        VStack {
                            Text(response.save.request?.type ?? "")
                            HStack {
                                Text(response.save.date.stringDate)
                                HStack {
                                    Text("\(response.save.grade)")
                                    Text("\(response.resultPercent)")
                                    Text(response.save.request?.difficulty.rawValue ?? "")
                                }
                            }
                        }
                    }
                    Divider()
                }
            }
            .background {
                Color.white.opacity(0.12)
                    .blur(radius: 50)
                    .cornerRadius(12)
            }
        }
        .background {
            ClearBackgroundView()
        }
        .navigationTitle(selectedCategory)
    }
}
