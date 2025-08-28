//
//  AppData.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import SwiftUI
import Combine

class LocalDataBaseManager:ObservableObject {
    private let dbkey = "db8"
    @Published var deviceSize:CGSize = .zero
    static let adviceLimit:Int = 4
    @Published var db:DataBase = .init() {
        didSet {
            if dataLoaded {
                if Thread.isMainThread {
                    DispatchQueue(label: "db", qos: .userInitiated).async {
                        UserDefaults.standard.set(self.db.decode ?? .init(), forKey: self.dbkey)
                    }
                } else {
                    UserDefaults.standard.set(self.db.decode ?? .init(), forKey: dbkey)
                }
            } else {
                dataLoaded = true
            }
        }
    }
    
    init() {
        self.fetch()
    }

    @Published var sheetPresenting: Bool = false


    private var dataLoaded = false
    
    func fetch() {
        if Thread.isMainThread {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.performFetchDB()
            }
        }
        else {
            self.performFetchDB()
            
        }
    }

    @Published var adPresenting:Bool = false
    @Published var adPresentingValue:Set<AnyCancellable> = []

    @Published var navHeight:CGFloat = .zero
    @Published var navHeightValue:Set<AnyCancellable> = []

    private func performFetchDB() {
        let db = UserDefaults.standard.data(forKey: dbkey)
        DispatchQueue.main.async {
            self.dataLoaded = false
            self.db = .configure(db) ?? .init()
        }
    }
}

struct DataBase: Codable {
    var responses: [AdviceQuestionModel] = []
    var network: Network = .init()

    private var _tutorialssssssssssssssssss: Tutorial?
    var tutorials: Tutorial {
        get {
            _tutorialssssssssssssssssss ?? .init()
        }
        set {
            _tutorialssssssssssssssssss = newValue
        }
    }

    struct Network: Codable {
        var settings: NetworkResponse.CategoriesResponse.AppData.Settings? = nil
    }
}

extension DataBase {
    struct Tutorial: Codable {
        private var completed: [TutorialType] = []

        func needPresenting(
            after: TutorialType?
            //_ type: [TutorialType] = TutorialType.allCases
        ) -> TutorialType? {
            guard let type = after ?? nextInCompleted else {
                return nil
            }

            if after == nil && !completed.isEmpty {
                return TutorialType.allCases.first
            }
            let nextIndex = type.index + (after == nil ? 0 : 1)
            if nextIndex <= TutorialType.allCases.count - 1 {
                return TutorialType.allCases[nextIndex]
            } else {
                return nil
            }
        }

        private var nextInCompleted: TutorialType? {
            TutorialType.allCases.first(where: {//type.first(where: {
                !completed.contains($0)
            })
        }

        mutating func complete(_ type: TutorialType) -> TutorialType? {
            if !completed.contains(type) {
                completed.append(type)
            }
            return needPresenting(after: type)
//            if needPresenting(after: type) != nil {
//                completed.append(type)
//            }
//            return TutorialType.allCases.first(where: {
//                needPresenting(after: $0) != nil
//            })
        }

        /// - upon completion, next type is setted, in the order declared in .allCases
        enum TutorialType: String, Codable, CaseIterable {
            case selectParentCategory, selectType, difficulty
            case pressGenerate, selectOption, swipeOption,
                 waitingForSqueezeCompletion, generateResult
            case selectTypeDB, pressTypeDetailDB

            var index: Int {
                Self.allCases.firstIndex(of: self) ?? 0
            }
            //wellcome, home,
        }
    }
}
