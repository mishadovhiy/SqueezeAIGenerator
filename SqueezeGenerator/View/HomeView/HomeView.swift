import SwiftUI

enum NavRout: Hashable {
    case result
    case question(NetworkResponse.AdviceResponse.QuestionResponse)
}

struct HomeView: View {
    @State var appResponse: NetworkResponse.CategoriesResponse? {
        didSet {
            appDataLoading = false
        }
    }
    @State var collectionData: [CollectionViewController.CollectionData] = []
    @State var response: AdviceQuestionModel?
    @State var totalGrade: Int = 0
    @State var category: String = ""
    @State var description: String = ""
    @State var type: String = ""
    @State var navValues: [NavRout] = []
    @EnvironmentObject var db: AppData
    @State var rqStarted: Bool = false
    @State var textPresenting: Bool = false
    @State var dbPresenting: Bool = false
    @State var selectedIDs: [String] = [] {
        didSet {
            print(selectedIDs, " tgerfwd ")
            self.updateTableData()
        }
    }
    @State var appDataLoading: Bool = true
    
    var body: some View {
        VStack(spacing: 15) {
            if let _ = appResponse {
                if let _ = response {
                    headerView
                    navigationStack
                    buttonsView
                } else {
                    homeView
                }
            } else if appDataLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text("Error loading app data")
            }
        }
        
        .padding()
        .background(content: {HomeBackgroundView()})
        .sheet(isPresented: $textPresenting, content: {
            TextView(text: response?.response.textHolder ?? "??", needScroll: true)
        })
        .sheet(isPresented: $dbPresenting) {
            DBView()
        }
        .task(priority: .userInitiated) {
            NetworkModel().appData { response in
                db.db.network.settings = response?.appData.settings
                DispatchQueue.main.async {
                    self.appResponse = response
                    self.updateTableData()
                    
                }
            }
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
        .init(title: response.name, id: response.id, parentID: parentID)
    }
    
    var buttonsView: some View {
        VStack(spacing: 10) {
            if currentQuestion == nil {
                Button("Start") {
                    navValues.append(.question(response!.response.questions.first!))
                    
                }
            }
            actionButtonsView
        }
    }
    
    var actionButtonsView: some View {
        ForEach(currentQuestion?.options ?? [], id: \.id) { option in
            Button(option.optionName + " (\(option.grade))") {
                //                totalGrade += option.grade
                response?.save.questionResults.updateValue(option, forKey: currentQuestion!)
                let i = navValues.count
                if response!.response.questions.count > i {
                    navValues.append(.question(response!.response.questions[i]))
                    
                } else {
                    navValues.append(.result)
                }
            }
        }
    }
    
    @ViewBuilder
    var homeView: some View {
        if rqStarted {
            ProgressView().progressViewStyle(.circular)
        } else {
            Button("db") {
                self.dbPresenting = true
            }
            Spacer()
            requestEditorView
        }
    }
    
    var headerView: some View {
        HStack {
            Text("\(response?.save.grade ?? 0) / \(response?.response.questions.totalGrade ?? 0)")
            Spacer()
            Button("text") {
                textPresenting = true
            }
        }
        .frame(height: 44)
    }
    
    var navigationStack: some View {
        NavigationStack(path: $navValues) {
            VStack(content: {
                Color.clear
            })
            .background(.clear)
            .background {
                ClearBackgroundView()
            }
            .navigationDestination(for: NavRout.self) { navRout in
                navigationDestination(for: navRout)
                    .background {
                        ClearBackgroundView()
                    }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background {
            ClearBackgroundView()
        }
    }
    
    @ViewBuilder
    func navigationDestination(for rout: NavRout) -> some View {
        switch rout {
        case .question(let response):
            SqueezeView(response: response)
        case .result:
            ResultView(savePressed: .init(get: {
                false
            }, set: {
                if $0 {
                    savePressed()
                }
            }))
        }
    }
    @State var dataCount: Int = 5
    @State var contentHeight: CGFloat = 0
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
    @ViewBuilder
    var requestEditorView: some View {
        let `default` = NetworkRequest.SqueezeRequest.default
        TextField(`default`.category, text: $category)
        TextField(`default`.type, text: $type)
        TextField(`default`.description, text: $description)
        Spacer().frame(height: 15)
        ScrollView(.vertical) {
            VStack {
                CollectionView(contentHeight: $contentHeight, data: collectionData, didSelect: { at in
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
                            self.startGenerationRequest(selected.name, category: parentTitle ?? self.category, description: selected.description)
                            //go to difficulty
                        }
                    } else {
                        fatalError()
                    }
                })
                
            }
            .frame(height: contentHeight)
        }
        .frame(maxHeight: .infinity)
        Button("squuze") {
            startGenerationRequest(type, category: category, description: description)
        }
    }
    
    func startGenerationRequest(_ type: String, category: String, description: String) {
        self.rqStarted = true
        Task(priority: .userInitiated) {
            NetworkModel().advice(.init(type: type, category: category, description: description)) { response in
                self.response = .init(response: response!, save: .init())
            }
        }
    }
    
    var currentQuestion: NetworkResponse.AdviceResponse.QuestionResponse? {
        if let last = navValues.last {
            return switch last {
            case .result:
                nil
            case .question(let questionResponse):
                questionResponse
            }
        } else {
            return nil
        }
    }
    
    func savePressed() {
        //        response?.save = .init(grade: totalGrade, category: "Shiz")
        db.db.responses.append(response!)
        // navValues = []
        navValues.removeAll()
        response = nil
        rqStarted = false
    }
}

struct TextView: View {
    let text: String
    let needScroll: Bool
    
    var body: some View {
        if needScroll {
            ScrollView(.vertical) {
                Text(text)
            }
        } else {
            Text(text)
        }
    }
}

struct DBView: View {
    @EnvironmentObject var db: AppData
    
    var body: some View {
        NavigationStack {
            VStack {
                if db.db.responses.isEmpty {
                    Text("No values")
                }
                ScrollView {
                    VStack {
                        ForEach(db.db.responses, id: \.id) { response in
                            NavigationLink("\(response.save.category ?? "") = \(response.save.grade ?? 0)") {
                                DBDetailView(item: response)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct DBDetailView: View {
    let item: AdviceQuestionModel
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    Text("\(item.save.grade ?? 0)")
                    Spacer()
                    Text("\(item.save.category ?? "")")
                }
                Divider()
                TextView(text: item.response.textHolder, needScroll: false)
                
                
            }
        }
    }
    
}

struct SqueezeView: View, Hashable {
    let response: NetworkResponse.AdviceResponse.QuestionResponse
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(response.questionName)
                Text(response.description)
                    .opacity(0.5)
            }
            Spacer()
        }
        .onAppear {
            print(response.questionName, " uyhtyrgtefrd ")
        }
    }
}

struct ResultView: View, Hashable, Equatable {
    static func == (lhs: ResultView, rhs: ResultView) -> Bool {
        // Comparing the state that matters for equality
        return lhs.savePressed == rhs.savePressed
    }
    
    // Hashing function
    func hash(into hasher: inout Hasher) {
        // Hash the properties that define uniqueness
        hasher.combine(savePressed)
    }
    
    
    @Binding var savePressed: Bool
    var body: some View {
        Button("save", action: {
            savePressed = true
        })
    }
}
