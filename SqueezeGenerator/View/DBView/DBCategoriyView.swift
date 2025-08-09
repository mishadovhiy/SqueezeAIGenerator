//
//  DBCategoriyView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 04.08.2025.
//

import SwiftUI

struct DBCategoriyView: View {

    @EnvironmentObject private var db: AppData
    let presenter: Presenter

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews:[.sectionHeaders], content: {
                viewTitle
                Section {
                    tableView
                } header: {
                    header
                }
            })
        }
        .background {
            ClearBackgroundView()
        }
        .navigationTitle(presenter.selectedCategory)
    }

    var viewTitle: some View {
        Text(presenter.selectedType)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
            .padding(.horizontal, 10)
    }

    var tableView: some View {
        VStack {
            if data.isEmpty {
                Text("no saved data")
            }
            listView
        }
        .background {
            sectionBackground
        }
        .padding(.horizontal, 10)
    }

    var sectionBackground: some View {
        Color.black.opacity(0.12)
            .overlay(content: {
                BlurView()
            })
            .cornerRadius(12)
    }

    var header: some View {
        HStack(content: {
            HStack {
                ForEach(SortingKeys.allCases, id: \.rawValue) { key in
                    Button {
                        withAnimation(.smooth) {
                            if sortingKey == key {
                                sortingPositive.toggle()
                            }
                            self.sortingKey = key
                        }
                        print(key.rawValue, " etgrwfedaws ")
                    } label: {
                        HStack(spacing: 2) {
                            if !key.needSpacer {
                                self.sortIndicator(sortingKey == key)
                            }

                            Text(key.rawValue.capitalized)
                            if key.needSpacer {
                                self.sortIndicator(sortingKey == key)
                            }
                        }

                            .foregroundColor(.white.opacity(0.5))
                    }

                    if key.needSpacer {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 30)
//            .opacity(0.5)
            .padding(.vertical, 10)
        })
        .frame(maxWidth: .infinity)
        .background(content: {
            BlurView()
                .frame(maxWidth: .infinity)
                .background(.black.opacity(0.15))
                .ignoresSafeArea(.all)
        })
    }

    func sortIndicator(_ isSelected: Bool) -> some View {
        Image(systemName: "control")
            .rotationEffect(.degrees(sortingPositive ? 180 : 0))
            .opacity(isSelected ? 1 : 0)
            .animation(.smooth, value: sortingPositive)
    }

    func responseCell(_ response: AdviceQuestionModel) -> some View {
        VStack {
            HStack {
                Text(response.save.date.stringDate)

                Spacer()
                HStack(spacing: 30) {
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

    var listView: some View {
        ForEach(data, id: \.id) { response in
            NavigationLink(value: NavRout.dbDetail(response)) {
                responseCell(response)
            }
            Divider()
        }
    }

    @State var sortingKey: SortingKeys = .date
    @State var sortingPositive: Bool = true

    private var data: [AdviceQuestionModel] {
        db.db.responses.filter({
            $0.save.request?.type == presenter.selectedType
        }).sorted { model1, model2 in
            switch sortingKey {
            case .score:
                if sortingPositive {
return model1.resultPercent >= model2.resultPercent
                } else {
                    return model1.resultPercent <= model2.resultPercent
                }

            case .difficulty:
                if sortingPositive {
return model1.save.request?.difficulty?.rawValue ?? "" >= model2.save.request?.difficulty?.rawValue ?? ""

                } else {
                    return                 model1.save.request?.difficulty?.rawValue ?? "" <= model2.save.request?.difficulty?.rawValue ?? ""

                }
            default:
                if sortingPositive {
                    return model1.save.date >= model2.save.date
                } else {
                    return model1.save.date <= model2.save.date
                }
            }
        }
    }
}

extension DBCategoriyView {
    enum SortingKeys: String, CaseIterable {
        case date, score, difficulty

        var needSpacer: Bool {
            self == .date
        }
    }
}

extension DBCategoriyView {
    struct Presenter: Equatable, Hashable {
        let selectedCategory: String
        let selectedType: String
    }
}
