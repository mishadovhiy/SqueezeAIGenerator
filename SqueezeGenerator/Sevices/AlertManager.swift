//
//  AlertManager.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import SwiftUI

struct AlertManager {
    private var messageHolder: [AlertContentModel] = []

    var currentMessage: AlertContentModel?

    mutating func dismiss() {
        print(messageHolder.count, " rtegrfwdsa ")
        if messageHolder.isEmpty {
            return
        }
        messageHolder.removeFirst()
        
        self.currentMessage = nil
        self.checkLast()
//        DispatchQueue.main.async {
//            withAnimation(.bouncy(duration: 0.3)) {
//                self.currentMessage = nil
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
//                print("checklast")
//                self.checkLast()
//            })
//        }
    }

    mutating func present(_ message: AlertContentModel) {
        messageHolder.append(message)
        self.checkLast()
    }

    private mutating func checkLast() {
        if currentMessage != nil {
            return
        }
        currentMessage = messageHolder.first
        print(currentMessage, " hyrtgerfwd ")
    }

}
