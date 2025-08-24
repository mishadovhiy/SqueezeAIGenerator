//
//  HomeViewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    var dbHolder: [AdviceQuestionModel] = []
    @Published var selectedGeneralKeyID: String?
    @Published var collectionDataForKey: [CollectionViewController.CollectionData] = []
    @Published var appResponse: NetworkResponse.CategoriesResponse?
    @Published var collectionData: [CollectionViewController.CollectionData] = []
    @Published var response: AdviceQuestionModel?
    @Published var selectedRequest: NetworkRequest.SqueezeRequest?
    @Published var category: String = ""
    @Published var description: String = ""
    @Published var type: String = ""
    @Published var navValues: [NavRout] = []
    @Published var rqStarted: Bool = false
    @Published var textPresenting: Bool = false
    @Published var dbPresenting: Bool = false
    @Published var selectedIDs: [String] = []
    @Published var appDataLoading: Bool = true
    @Published var dataCount: Int = 5
    @Published var contentHeight: CGFloat = 0
#warning("tood: refactor - rename")
    @Published var scrollPosition: ScrollReaderModifier.ScrollResult = .init()
    @Published var viewSize: CGFloat = .zero
    var statsPreview: [String: ResponsePreviewModel] = [:]
    var largeParentCollections: Bool {
        selectedGeneralKeyID == nil
    }
    var selectedCategory: NetworkResponse.CategoriesResponse.Categories? {
        appResponse?.categories.first(where: {
            $0.id == self.selectedGeneralKeyID
        })
    }
    var backgroundProperties: HomeBackgroundView.BakcgroundProperties {
        let resp = self.convertToAllLists(list: self.appResponse?.categories ?? [])

        let lastResponse = resp.first(where: {
            $0.id == selectedIDs.last
        })
        let background: NetworkResponse.CategoriesResponse.Categories.Color? = selectedRequest?.color ?? (lastResponse?.color ?? appResponse?.categories.first(where: {
            $0.id == self.selectedGeneralKeyID
        })?.color)
        if scrollPosition.position.y - (viewSize / 1.2) <= .zero && navValues.isEmpty {
            var alpha = 1 - ((scrollPosition.position.y - (viewSize / 1.2)) / 20)
            let max: CGFloat = 12
            if alpha >= max {
                alpha = max
            }
            return  .init(blurAlpha: alpha,
                          backgroundGradient: background)
        }
        return .init(
            needOval: navValues.isEmpty,
            illustrationScale: navValues.isEmpty ? (selectedRequest == nil ? 1 : 0.5) : (
                navValues.last?.illustrationScale ?? 0
            ),
            backgroundGradient: background
        )
    }

    //shows buttons view across navigations
    private var needButtonsView: Bool {
        navValues.last?.needDoneButton ?? false || (response != nil && navValues.isEmpty)
    }

    //shows buttons view across navigations
    var buttonsViewHeight: CGFloat {
        needButtonsView ? 55 : 0
    }

    var gradientOpacity: CGFloat {
        if !navValues.isEmpty {
            return 0
        }
        if scrollPosition.position.y <= 320 {
            let calc = (320 - scrollPosition.position.y) / 100
            if calc >= 1 {
                return 1
            }
            if calc <= 0 {
                return 1
            }
            return calc
        } else {
            return 0
        }
    }

    let maxCollectionPaddings: CGFloat = .Padding.content.rawValue
    var collectionSubviewPaddings: CGFloat {
        maxCollectionPaddings - (selectedGeneralKeyID != nil ? 10 : 0)
    }

    var circleType: HomeBackgroundView.`Type` {
        if appDataLoading || requestLoading {
            return .loading
        }
        if !navValues.isEmpty {
            if !(response?.response.questions.isEmpty ?? true) {
                return .topBig
            }
            return .regular
        } else {
            if response != nil {
                return .regular
            }
            return scrollPosition.position.y <= 250 ? .regular : .topRegular
        }
    }
    func findSelectedCategory(cats: [NetworkResponse.CategoriesResponse.Categories], selectedID: String) -> NetworkResponse.CategoriesResponse.Categories? {
        if let selectedCat = cats.first(where: {
            $0.id == selectedID
        }) {
            return selectedCat
        } else {
            if let selected = cats.first(where: {
                $0.list?.contains(where: {
                    $0.id == selectedID
                }) ?? false
            }) {
                return selected.list?.first(where: {
                    $0.id == selectedID
                })
            } else {
                let array = cats.compactMap({$0.list}).flatMap({$0})
                if !array.isEmpty {
                    return findSelectedCategory(cats: array, selectedID: selectedID)
                } else {
                    return nil
                }
            }
        }
    }

    func actionButtonPressed(_ option: NetworkResponse.AdviceResponse.QuestionResponse.Option) {
        response?.save.questionResults.updateValue(option, forKey: currentQuestion!)
        let i = navValues.count
        if response!.response.questions.count > i {
            navValues.append(.question(response!.response.questions[i]))

        } else {
            navValues.append(.result)
        }
    }

    func parentSubcategories(list: [NetworkResponse.CategoriesResponse.Categories]) ->  [NetworkResponse.CategoriesResponse.Categories] {
        if let subList = list.first(where: {
            $0.list != nil
        }) {
            var list = list.filter({
                $0.id != subList.id
            })
            var subList = subList
            subList.list = nil
            list.append(subList)
            list.append(contentsOf: subList.list ?? [])
            return parentSubcategories(list: list)
        } else {
            return list
        }
    }

    func convertToAllLists(list: [NetworkResponse.CategoriesResponse.Categories], checkedIDs: [String] = []) -> [NetworkResponse.CategoriesResponse.Categories] {
        var checkedIDs = checkedIDs
        var newList = list.compactMap({
            $0.list
        }).flatMap({$0})
        checkedIDs.append(contentsOf: newList.compactMap({
            $0.id
        }))
        if newList.contains(where: {
            $0.list != nil && !checkedIDs.contains($0.id)
        }) {
            newList.append(contentsOf: list)
            return convertToAllLists(list: newList, checkedIDs: checkedIDs)
        } else {
            newList.append(contentsOf: list)
            return newList
        }
    }

    func findParents(id: String, found: [NetworkResponse.CategoriesResponse.Categories], totalList: [NetworkResponse.CategoriesResponse.Categories]) -> [NetworkResponse.CategoriesResponse.Categories] {
        print(id, " lookingfsd")
        if id.isEmpty {
            return found
        }
        if let parent = totalList.first(where: {
            $0.id == id
        }) {
            var found = found
            found.append(parent)

            if let collection = collectionData.first(where: {
                $0.id == parent.id
            }) {

                if !collection.parentID.isEmpty {

                    return findParents(id: collection.parentID, found: found, totalList: totalList)
                } else {
                    return found
                }
            } else {
                return found
            }
        } else {
            return found
        }
    }

    func parentCollectionSelected(_ item: CollectionViewController.CollectionData) {
        withAnimation {
            self.collectionDataForKey.removeAll()
            self.selectedIDs.removeAll()
            if self.selectedGeneralKeyID != item.id {
                self.selectedGeneralKeyID = item.id
                self.selectedIDs.append(item.id)
            } else {
                self.selectedGeneralKeyID = nil
                self.selectedIDs.removeAll()
            }
        }
        self.updateTableData()
    }

    func dbUpdated(_ db: AppData) {
        let db = db.db.responses
        self.statsPreview.removeAll()
        self.collectionData.forEach { data in
            let list = appResponse?.categories.first(where: {
                $0.id == data.id
            })?.list ?? []
            let newList = parentSubcategories(list: list)
            let parentDB = db.filter({ dbItem in
                newList.contains(where: {
                    $0.name == dbItem.save.request?.category
                })
            })
            print(parentDB.count, " htgrtefwdsax ", newList.count)
            //fetch all categories of the cat
            statsPreview.updateValue(
                .init(newList,
                      parentDB: parentDB),
                forKey: data.id)
        }
    }

    func updateTableData() {
        let firstUpdate = collectionData.isEmpty
        var collectionData = collectionData
        collectionData = (appResponse?.categories.filter({
            selectedIDs.contains($0.id)
        }).compactMap({
            performAddTableData($0, parentID: $0.id)
        }) ?? [])
        var response = appResponse?.categories.compactMap({
            self.performAddTableData($0, parentID: "")
        })
        print(collectionData.compactMap({$0.parentID}).joined(separator: ", "), " rewfedaws ")
        self.selectedIDs.forEach { id in
            let items = self.findSelectedCategory(cats: appResponse?.categories ?? [], selectedID: id)
            let index = collectionData.firstIndex(where: {
                $0.id == id
            })
            let newItems = items?.list?.compactMap({
                self.performAddTableData($0, parentID: id)
            }) ?? []
            if let index {
                collectionData.insert(contentsOf: newItems, at: index + 1)

            } else {
                withAnimation {
                    selectedIDs.removeAll(where: {
                        id == $0
                    })
                }
                //                collectionData.append(contentsOf: newItems)
            }

        }
        print(collectionDataForKey.compactMap({$0.parentID}).joined(separator: ", "), " juyhfvddvs ")

        //        appResponse?.categories.forEach { category in
        //            if let cats = category.list {
        //                self.checkTableDataIDs(cats, parentID: category.id, collectionData: &collectionData)
        //            }
        //        }
        withAnimation(.bouncy) {
            self.collectionData = response ?? []
            print(collectionData, " juyhtbgrvfecd")
            self.collectionDataForKey = collectionData.filter({
                $0.id != self.selectedGeneralKeyID
            })
        }
    }
    func checkTableDataIDs(_ response: [NetworkResponse.CategoriesResponse.Categories], parentID: String, collectionData: inout [CollectionViewController.CollectionData]) {
        print(selectedIDs, " htgbrvfecdsx")
        if selectedIDs.isEmpty {
            return
        }
        if selectedIDs.contains(parentID) {
            if let parentIndex = collectionData.firstIndex(where: {
                $0.id == parentID
            }) {
                collectionData.insert(contentsOf: response.compactMap({
                    self.performAddTableData($0, parentID: parentID)
                }), at: parentIndex + 1)
            } else {
                print("appdend: ", parentID)
                collectionData.append(contentsOf: response.compactMap({
                    self.performAddTableData($0, parentID: parentID)
                }))
            }
        } else {
            response.forEach { category in
                if let categories = category.list {
                    self.checkTableDataIDs(categories, parentID: category.id, collectionData: &collectionDataForKey)
                }
            }
        }
    }

    func performAddTableData(_ response: NetworkResponse.CategoriesResponse.Categories, parentID: String) -> CollectionViewController.CollectionData {
        let isListSelected: Bool
        let label: String
        let percent: String
        if response.list != nil {
            isListSelected = self.selectedIDs.contains(response.id)
            label = ""
            percent = ""
        } else {
            isListSelected = false
            if let dbData = dbHolder.last(where: {
                $0.save.request?.type == response.name
            }) {
                var value = dbData.resultPercent * 100
                print(value, " tgrtefrwdas ")
                if !value.isFinite {
                    value = 0
                }
                label = "\(dbHolder.filter({$0.save.request?.type == response.name}).count)"
                percent = "\(Int(value))"
            } else {
                label = ""
                percent = ""
            }

        }

        return .init(
            title: response.name.addSpaceBeforeCapitalizedLetters,
            cellBackground: isListSelected ? .yellow : (response.resultType != nil ? .white : .gray),
            isSelected: self.selectedIDs.contains(response.id),
            id: response.id,
            parentID: parentID,
            percent: percent,
            label: label,
            isType: response.resultType != nil,
            imageURL: response.imageURL ?? ""
        )
    }


    func savePressed(db: AppData) {
        //        response?.save = .init(grade: totalGrade, category: "Shiz")
        var response = response
        let selectedRequest = selectedCategory
//        db.db.responses.append(response!)
        // navValues = []
        print(response!.save.request?.category, " rtgerfeadsaads ", response!.save.request?.type)
        self.navValues = [.empty]
        DispatchQueue.main.async {
            Task(priority: .background) {
                NetworkModel()
                    .result(.init(parentCategory: response?.save.request?.parentCategory ?? "",
                                  category: response!.save.request?.type ?? "",
                                  gradePercent: "\(response?.resultPercentInt ?? 0)",
                                  scoreDescription: selectedRequest?.resultScoreDescription)) { [weak self] respos in
                        print(respos, " gerfwdasx ")
                        response?.save.aiResult = respos
                        db.db.responses.append(response!)
                        DispatchQueue.main.async {
                            withAnimation {
                                self?.navValues = [.resultResponse(respos!)]
                                self?.response = nil
                                self?.rqStarted = false
                                self?.selectedRequest = nil
                            }
                        }
                    }


            }
        }

    }

    var requestLoading: Bool {
        rqStarted && response == nil
    }

    func startGenerationRequest() {
        withAnimation(.smooth(duration: 0.3)) {
            self.rqStarted = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            Task(priority: .userInitiated) {
                //            let request = NetworkRequest.SqueezeRequest.init(type: type, category: category, description: description)
                NetworkModel().advice(self.selectedRequest!) { response in
                    DispatchQueue.main.async {
                        withAnimation {
                            self.response = .init(response: response!, save: .init(date: .init(), category: self.selectedRequest!.category, request: self.selectedRequest!, questionResults: [:]))
                            self.navValues.removeAll()
                        }
                    }
                }
            }
        })
    }

    func loadAppSettings(db: AppData) {
        NetworkModel().appData { response in
            db.db.network.settings = response?.appData.settings
            DispatchQueue.main.async {
                self.appResponse = response
                self.updateTableData()
                withAnimation {
                    self.appDataLoading = false
                }
            }
        }
    }

    var currentQuestion: NetworkResponse.AdviceResponse.QuestionResponse? {
        if let last = navValues.last {
            return switch last {
            case .question(let questionResponse):
                questionResponse
            default: nil
            }
        } else {
            return nil
        }
    }

    func collectionViewSelected(at: Int?) {
        let category = collectionDataForKey[at!]

        print(category, " drftgyhujilk")
        if let response = self.findSelectedCategory(cats: self.appResponse?.categories ?? [], selectedID: category.id) {
            if response.list != nil {
                if selectedIDs.contains(response.id) {
                    selectedIDs.removeAll(where: {
                        $0 == response.id
                    })
                } else {
                    withAnimation(.smooth) {
                        self.selectedIDs.append(response.id)
                    }
                }

                print(response.list, " grfsd")
            } else {
                print(category)
                let resp = self.convertToAllLists(list: self.appResponse?.categories ?? [])
                print("gterfweads")
                let selected = response
                let parent = resp.first(where: {
                    $0.id == category.parentID
                })
                let parents:[NetworkResponse.CategoriesResponse.Categories]
                print(parent?.id, " tegrfwed")
                if let parent {
                    parents = findParents(id: parent.id, found: [], totalList: resp).reversed()
                } else {
                    parents = []
                }
                var parentTitle:String? = parents.compactMap({
                    $0.name
                }).joined(separator: ", ")
                print(parentTitle, " gterfw", parent?.id)
                print(selected, " yrhtegrfse ", category.parentID)
                if parentTitle?.isEmpty ?? false {
                    parentTitle = nil
                }
                print(selected.color, " hytfre")
                let selectedCategory = appResponse?.categories.first(where: {
                    $0.id == self.selectedGeneralKeyID
                })
                withAnimation {
                    selectedRequest = .init(
                        type: selected.name,
                        category: selectedCategory?.name ?? "",
                        parentCategory: parentTitle ?? self.category,
                        description: selected.description,
                        color: selected.color ?? parent?.color
                    )
                }
                navValues
                    .append(
                        .requestToGenerateParameters(
                            selectedRequest!, selected
                        )
                    )
                //                self.startGenerationRequest(selected.name, category: parentTitle ?? self.category, description: selected.description)
                //go to difficulty
            }
        } else {
            fatalError()
        }
    }

    func selected(_ item: String?) {
        let data = appResponse?.categories.first(where: { response in
            response.id == item
        })?.list?.compactMap({
            performAddTableData($0, parentID: item ?? "")
        }) ?? []
        withAnimation {
            self.collectionDataForKey = data
        }
    }

    private func cardViewType(_ question: NetworkResponse.AdviceResponse.QuestionResponse) -> CardData {
        .init(
            title: question.questionName,
            description: question.description,
            id: question.id,
            buttons: question.options.compactMap(
                { button in
                    let selectedOption = response!.save.questionResults[question]
                    return .init(
                        title: button.optionName,
                        isSelected: selectedOption?.id == button.id,
                        id: button.id.uuidString,
                        extraSmall: true
                    )
                })
        )
    }

    func primaryButtonPressed() {
        if response != nil {
            navValues.append(
                .cardView(.init(
                    type: selectedRequest?.type ?? "",
                    data: response!.response.questions.compactMap(
                        { question in
                            cardViewType(question)
                        }
                    )
                ))
            )
        } else {
            withAnimation {
                navValues.append(.empty)
                startGenerationRequest()
            }
        }
    }
}
