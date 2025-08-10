//
//  AppData.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import SwiftUI
import Combine

class AppData:ObservableObject {
    private let dbkey = "db8"
    @Published var deviceSize:CGSize = .zero
    static let adviceLimit:Int = 4
    @Published var db:DataBase = .init() {
        didSet {
            print("updatingdb")
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
    
    struct Network: Codable {
        var settings: NetworkResponse.CategoriesResponse.AppData.Settings? = nil
    }
}
