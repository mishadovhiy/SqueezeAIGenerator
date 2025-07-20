import SwiftUI

enum NavRout: Hashable {
    case result
    case question(NetworkResponse.AdviceResponse.QuestionResponse)
}

struct ContentView: View {
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
        .sheet(isPresented: $textPresenting, content: {
            TextView(text: response?.response.textHolder ?? "??", needScroll: true)
        })
        .sheet(isPresented: $dbPresenting) {
            DBView()
        }
        .task(priority: .userInitiated) {
            NetworkModel().appData { response in
                DispatchQueue.main.async {
                    self.appResponse = response
                    self.coll
                }
            }
        }
    }
    @State var selectedIDs: [String] = []
    @State var appDataLoading: Bool = true
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
    @ViewBuilder
    var requestEditorView: some View {
        let `default` = NetworkRequest.SqueezeRequest.default
        TextField(`default`.category, text: $category)
        TextField(`default`.type, text: $type)
        TextField(`default`.description, text: $description)
        Spacer().frame(height: 15)
        ScrollView(.vertical) {
            VStack {
                CollectionView(contentHeight: $contentHeight, data: Array(0..<dataCount).compactMap({
                    .init(title: "adsasd\($0)")
                }))
                .background(.red)
            }
            .background(.orange)
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
        .background(.red)
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
