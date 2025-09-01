//
//  AlertManager.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import SwiftUI

// manages query of messages content data model
struct AlertManager {
    private var messageHolder: [AlertContentModel] = []

    var currentMessage: AlertContentModel?
    var dismissingMessage: AlertContentModel?
    
    mutating func dissmissAnimationCompleted() {
        self.currentMessage = nil
        self.dismissingMessage = nil
        self.checkLast()
    }
    
    mutating func dismiss() {
        if messageHolder.isEmpty {
            return
        }
        dismissingMessage = messageHolder.removeFirst()
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
    }
}
