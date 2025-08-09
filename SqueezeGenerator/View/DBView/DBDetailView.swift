//
//  DBDetailView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct DBDetailView: View {
    
    let item: AdviceQuestionModel
    @State var collectionHeights: [String: CGFloat] = [:]

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    VStack {
                        Text("Type")
                        Text(item.save.request?.type ?? "-")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Category")
                        Text(item.save.request?.category ?? "-")
                    }
                    .frame(maxWidth: .infinity)
                }
                VStack {
                    Text("Description")
                    Text(item.save.request?.description ?? "-")
                }
                HStack {
                    Text("\(item.save.grade)/\(item.response.questions.totalGrade)")
                    Text("questions: \(item.response.questions.count)")
                }
                Divider()
                ForEach(Array(item.save.questionResults.keys), id:\.id) { key in
                    VStack {
                        Text(key.questionName)
                        Text(key.description)
                        CollectionView(contentHeight: .init(get: {
                            collectionHeights[key.id.uuidString] ?? 0
                        }, set: {
                            collectionHeights.updateValue($0, forKey: key.id.uuidString)
                        }), data: key.options.compactMap({
                            .init(title: $0.optionName)
                        }))
                    }
                    Divider()
                }
                
            }
            .padding(10)
            .background(.black.opacity(0.2))
            .cornerRadius(12)
            .padding(10)
        }
        .navigationTitle("item.save.category")

        .background {
            ClearBackgroundView()
        }
    }
    
}
