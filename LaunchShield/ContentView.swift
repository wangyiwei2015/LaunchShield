//
//  ContentView.swift
//  LaunchShield
//
//  Created by leo on 2024-05-17.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct ContentView: View {
    
    let store = ManagedSettingsStore()
    
    @State private var appSelecting = false
    @State private var appSelection: FamilyActivitySelection = .init()
    var appInfo: [Application] {
        appSelection.applications.sorted(by: {$0.bundleIdentifier! < $1.bundleIdentifier!})
    }
    @State var blocking = false
    
    var body: some View {
        VStack {
            if appInfo.isEmpty {
                Text("No app selected")
            } else {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(0..<appInfo.count, id: \.self) { i in
                            HStack {
                                Text(appInfo[i].localizedDisplayName!)
                                    .bold()
                                    .foregroundColor(.black)
                                Text(appInfo[i].bundleIdentifier!)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
            }
            Button("Choose apps") {
                appSelecting = true
            }
            Toggle("Blocking", systemImage: "swift", isOn: $blocking)
        }
        .padding()
        
        .familyActivityPicker(
            isPresented: $appSelecting,
            selection: $appSelection
        )
        
        .onChange(of: blocking) { _, newValue in
            if newValue {
                startBlocking()
            } else {
                stopBlocking()
            }
        }
    }
    
    func startBlocking() {
        //store.application.denyAppRemoval = true
        store.shield.applicationCategories = .specific(appSelection.categoryTokens)
        store.shield.applications = appSelection.applicationTokens
    }
    
    func stopBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.clearAllSettings()
    }
}

#Preview {
    ContentView()
}
