//
//  DBView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import SwiftUI

struct DBView: View {
    @EnvironmentObject private var db: AppData
    @Environment(\.dismiss) private var dismiss
        
    var responseList: some View {
        ForEach(Array(Set(db.db.responses.compactMap({
            $0.save.request?.type ?? ""
        }))), id: \.self) { response in
            NavigationLink {
                DBCategoriyView(selectedCategory: db.db.responses.first(where: {$0.save.request?.type == response})?.save.category ?? "", selectedType: response)
            } label: {
                VStack {
                    Text(response)
                }
                .background(.white)
            }
        }
    }
    
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
                        responseList
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
