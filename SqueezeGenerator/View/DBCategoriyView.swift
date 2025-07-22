//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct DBCategoriyView: View {
    @EnvironmentObject var db: AppData
    let selectedCategory: String
    var data: [AdviceQuestionModel] {
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
                            Text("\(response.save.category ?? "") = \(response.save.grade ?? 0)")
                        }
                        .background(.white)
                    }
                }
            }
        }
        .background {
            ClearBackgroundView()
        }
    }
}
