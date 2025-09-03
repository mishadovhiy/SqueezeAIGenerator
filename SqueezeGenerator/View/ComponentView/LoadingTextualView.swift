//
//  LoadingTextualView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 25.08.2025.
//

import SwiftUI

struct LoadingTextualView: View {

    let title: String
    @State private var dotes: String = "..."

    init(presenter: Presenter) {
        self.title = presenter.title
    }

    @State private var isDisapeared = false

    var body: some View {
        VStack(content: {
            Spacer()
                .frame(maxHeight: .infinity)
            Spacer()
                .frame(maxHeight: .infinity)
            Text(title)
                .font(.Type.section.font)
                .overlay {
                    HStack {
                        Spacer().frame(maxWidth: .infinity)
                        Text(dotes)

                            .multilineTextAlignment(.leading)
                            .frame(width: 40, alignment: .leading)
                            .offset(x: 40)
                    }
                }
                .foregroundColor(.white)
                .opacity(.Opacity.background.rawValue)
            Spacer()
                .frame(maxHeight: .infinity)
        })
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .onAppear {
            animateDote()
        }
        .onDisappear {
            isDisapeared = true
        }
    }


    func animateDote() {
        if isDisapeared {
            return
        }
        if dotes.count >= 3 {
            dotes = ""
        } else {
            dotes += "."
        }
        print(dotes)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.animateDote()
        })
    }
}

extension LoadingTextualView {
    struct Presenter: Equatable, Hashable {
        let title: String

        init(title: String = "Generating") {
            self.title = title
        }
    }
}

