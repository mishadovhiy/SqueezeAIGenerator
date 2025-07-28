//
//  HomeViewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
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
    @Published var scrollPosition: CGPoint = .zero
    @Published var viewSize: CGFloat = .zero
    var backgroundProperties: HomeBackgroundView.BakcgroundProperties {
        if scrollPosition.y - 250 <= .zero && navValues.isEmpty {
            var alpha = 1 - ((scrollPosition.y - 250) / 10)
            let max: CGFloat = 16
            if alpha >= max {
                alpha = max
            }
            return  .init(blurAlpha: alpha)
        }
        return .init()
    }
    
    var gradientOpacity: CGFloat {
        if !navValues.isEmpty {
            return 0
        }
        if scrollPosition.y <= 250 {
            let calc = (250 - scrollPosition.y) / 100
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
            return scrollPosition.y <= 250 ? .regular : .topRegular
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
    func updateTableData() {
        var collectionData = collectionData
        collectionData = (appResponse?.categories ?? []).compactMap({
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
                selectedIDs.removeAll(where: {
                    id == $0
                })
                //                collectionData.append(contentsOf: newItems)
            }
            
        }
        print(collectionData.compactMap({$0.parentID}).joined(separator: ", "), " juyhfvddvs ")
        
        //        appResponse?.categories.forEach { category in
        //            if let cats = category.list {
        //                self.checkTableDataIDs(cats, parentID: category.id, collectionData: &collectionData)
        //            }
        //        }
        withAnimation(.bouncy) {
            self.collectionData = collectionData
        }
    }
    func checkTableDataIDs(_ response: [NetworkResponse.CategoriesResponse.Categories], parentID: String, collectionData: inout [CollectionViewController.CollectionData]) {
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
                    self.checkTableDataIDs(categories, parentID: category.id, collectionData: &collectionData)
                }
            }
        }
    }
    
    func performAddTableData(_ response: NetworkResponse.CategoriesResponse.Categories, parentID: String) -> CollectionViewController.CollectionData {
        let isListSelected: Bool
        if response.list != nil {
            isListSelected = self.selectedIDs.contains(response.id)
        } else {
            isListSelected = false
        }
        return .init(title: response.name, cellBackground: isListSelected ? .yellow : (response.resultType != nil ? .white : .gray), id: response.id, parentID: parentID, isType: response.resultType != nil)
    }
    
    
    func savePressed(db: AppData) {
        //        response?.save = .init(grade: totalGrade, category: "Shiz")
        db.db.responses.append(response!)
        // navValues = []
        withAnimation {
            navValues.removeAll()
            response = nil
            rqStarted = false
            selectedRequest = nil
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
        let category = collectionData[at!]
        if let response = self.findSelectedCategory(cats: self.appResponse?.categories ?? [], selectedID: category.id) {
            if response.list != nil {
                if selectedIDs.contains(response.id) {
                    selectedIDs.removeAll(where: {
                        $0 == response.id
                    })
                } else {
                    self.selectedIDs.append(response.id)
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
                selectedRequest = .init(type: selected.name, category: parentTitle ?? self.category, description: selected.description)
                navValues.append(.requestToGenerateParameters(.init(type: selected.name, category: parentTitle ?? self.category, description: selected.description)))
//                self.startGenerationRequest(selected.name, category: parentTitle ?? self.category, description: selected.description)
                //go to difficulty
            }
        } else {
            fatalError()
        }
    }
}
