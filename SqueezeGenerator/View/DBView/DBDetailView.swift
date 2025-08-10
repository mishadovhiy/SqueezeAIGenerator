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
    @EnvironmentObject var db: AppData
    @State var initialNavHeight: CGFloat?
    //percent navigation title height is changed
    var navigationStatePercent: CGFloat {
        let value = db.navHeight / (initialNavHeight ?? 0)
        if value.isFinite {
            return value
        } else {
            return 1
        }

    }
    var navigationStatePercentMax: CGFloat {
        let value = navigationStatePercent
        if value >= 1 {
            return 1
        } else {
            return value
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    VStack {
                        Text("Type")
                        Text(item.save.request?.type ?? "")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Description")
                        Text(item.save.request?.description ?? "-")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(10)

                LazyVStack(pinnedViews: .sectionHeaders) {

                    Section {
                        dataSection
                            .padding(10)
                            .background(content: {
                                BlurView()
                            })
                            .background(.black.opacity(0.2))
                            .cornerRadius(16)
                            .padding(10)

                    } header: {
                        sectionHeader
                            .padding(.vertical, (10 * navigationStatePercent))

                            .background(content: {
                                BlurView()
                            })
                            .background(.black.opacity(0.4 * (1 - navigationStatePercentMax)))
                    }

                }
            }
        }
        .navigationTitle(item.save.request?.category ?? "-")

        .background {
            ClearBackgroundView()
        }
        .onChange(of: db.navHeight) { newValue in
            if initialNavHeight == nil {
                initialNavHeight = newValue
            }
            print(newValue, " terfwdsa ")
        }
    }

    var sectionHeader: some View {
        HStack {
            Text("\(item.save.grade)/\(item.response.questions.totalGrade) (\(item.resultPercentInt)%)")
                .frame(maxWidth: .infinity)
            Text("questions: \(item.response.questions.count)")
                .frame(maxWidth: .infinity)
        }
    }

    var dataSection: some View {
        VStack {
            ForEach(Array(item.save.questionResults.keys), id:\.id) { key in
                VStack {
                    Text(key.questionName)
                    Text(key.description)
                    CollectionView(
                        contentHeight: .init(get: {
                            collectionHeights[key.id.uuidString] ?? 0
                        }, set: {
                            collectionHeights.updateValue($0, forKey: key.id.uuidString)
                        }),
                        isopacityCells: false,
                        data: key.options.compactMap({
                            .init(title: $0.optionName)
                        })
                    )
                    .frame(height: collectionHeights[key.id.uuidString] ?? 0)
                }
                Divider()
            }
        }
    }
}
