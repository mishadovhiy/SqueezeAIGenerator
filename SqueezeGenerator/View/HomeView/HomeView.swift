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
        .opacity(dbPresenting ? 0 : 1)
        .animation(.smooth(duration: 1.2), value: dbPresenting)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .padding()
        .background(content: {HomeBackgroundView()})
        .fullScreenCover(isPresented: $dbPresenting, content: {
            DBView()
        })
        .sheet(isPresented: $textPresenting) {
            TextView(text: response?.response.textHolder ?? "??", needScroll: true)
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
                Text("request is ready")
            })
            .background {
                ClearBackgroundView()
            }
            .navigationDestination(for: NavRout.self) { navRout in
                navigationDestination(for: navRout)
                    .background {
                        ClearBackgroundView()
                    }
            }
            .background {
                ClearBackgroundView()
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
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    Spacer().frame(height: proxy.size.height * 0.8)
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
                    .frame(height: contentHeight)
                }
            }
        }
    }
    
    func startGenerationRequest(_ type: String, category: String, description: String) {
        self.rqStarted = true
        Task(priority: .userInitiated) {
            let request = NetworkRequest.SqueezeRequest.init(type: type, category: category, description: description)
            NetworkModel().advice(request) { response in
                self.response = .init(response: response!, save: .init(category: category, request: request, questionResults: [:]))
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
                    }
                    .background(.white)
                }
            }
        }
        .background {
            ClearBackgroundView()
        }
    }
}

struct DBView: View {
    @EnvironmentObject var db: AppData
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Button("close") {
                                dismiss.callAsFunction()
                            }
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        if db.db.responses.isEmpty {
                            Text("No values")
                        }
                        ForEach(Array(Set(db.db.responses.compactMap({
                            $0.save.request?.category ?? ""
                        }))), id: \.self) { response in
                            NavigationLink {
                                DBCategoriyView(selectedCategory: response)
                            } label: {
                                VStack {
                                    Text(response + "d")
                                }
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
        .background {
            ClearBackgroundView()
        }
    }
}

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
        .background {
            ClearBackgroundView()
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
