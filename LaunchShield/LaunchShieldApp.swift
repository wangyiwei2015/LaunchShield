//
//  LaunchShieldApp.swift
//  LaunchShield
//
//  Created by leo on 2024-05-17.
//

import SwiftUI
import FamilyControls

@main
struct LaunchShieldApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            try await AuthorizationCenter
                                .shared.requestAuthorization(for: .individual)
                        } catch {
                            // Handle the error here.
                        }
                    } // Task
                } // onAppear
        } // WindowGroup
    } // body
}
