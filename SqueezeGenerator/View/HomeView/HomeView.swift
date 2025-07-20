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
                    self.collectionData = (response?.categories ?? []).compactMap({
                        self.performAddTableData($0)
                    })
                    
                }
            }
        }
    }
    func updateTableData() {
        var collectionData = collectionData
        collectionData = (appResponse?.categories ?? []).compactMap({ .init(title: $0.name , id: $0.id) })
        self.selectedIDs.forEach { id in
            let items = self.findSelectedCategory(cats: appResponse?.categories ?? [], selectedID: id)
            let index = collectionData.firstIndex(where: {
                $0.id == id
            })
            let newItems = items?.list?.compactMap({
                self.performAddTableData($0)
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
                    self.performAddTableData($0)
                }), at: parentIndex + 1)
            } else {
                print("appdend: ", parentID)
                collectionData.append(contentsOf: response.compactMap({
                    self.performAddTableData($0)
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
    
    func performAddTableData(_ response: NetworkResponse.CategoriesResponse.Categories) -> CollectionViewController.CollectionData {
        .init(title: response.name, id: response.id)
    }
    
    var buttonsView: some View {
        VStack {
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
                totalGrade += option.grade
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
            Text("\(totalGrade)")
            Spacer()
            Button("text") {
                textPresenting = true
            }
        }
        .frame(height: 44)
    }
    
    var navigationStack: some View {
        NavigationStack(path: $navValues) {
            EmptyView()
                .navigationDestination(for: NavRout.self) { navRout in
                    navigationDestination(for: navRout)
                }
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
                            fatalError()
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
            self.rqStarted = true
            Task(priority: .userInitiated) {
                NetworkModel().advice(.init(type: type, category: category, description: description)) { response in
                    self.response = .init(response: response!, save: .init())
                }
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
//                    VStack {
//                        ForEach(db.db.responses, id: \.id) { response in
//                            NavigationLink("\(response.save?.category ?? "") = \(response.save?.grade ?? 0)") {
//                                DBDetailView(item: response)
//                            }
//                        }
//                    }
                }
            }
        }
    }
}

struct DBDetailView: View {
//    let item:NetworkResponse.AdviceResponse
//    var body: some View {
//        ScrollView(.vertical) {
//            VStack {
//                HStack {
//                    Text("\(item.save?.grade ?? 0)")
//                    Spacer()
//                    Text("\(item.save?.category ?? "")")
//                }
//                Divider()
//                TextView(text: item.textHolder, needScroll: false)
//                
//                
//            }
//        }
//    }
    var body: some View {
        Text("")
    }
}

struct SqueezeView: View, Hashable {
    let response: NetworkResponse.AdviceResponse.QuestionResponse
    var body: some View {
        VStack {
            Spacer()
            Text(response.questionName)
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
