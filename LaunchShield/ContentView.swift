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
    
    //@AppStorage("_APP_SELECTION_0") var sel: Set<Application>
    
    @State private var appSelecting = false
    @State private var appSelection: FamilyActivitySelection = .init()
    var appInfo: [Application] {
        appSelection.applications.sorted(by: {$0.hashValue < $1.hashValue})
    }
    @State var blocking = false
    @State var hiding = false
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    AppSelectedGroupView(
                        title: "some app group title", groupID: "some id maybe uuid type",
                        selection: $appSelection
                    )
                }
            }
            
            HStack {
                Image(systemName: "shield.slash")
                Image(systemName: "lock.shield")
                Image(systemName: "staroflife.shield")
            }.font(.title2).padding()
            
            Text(appInfo.isEmpty ? "No app selected" : "\(appInfo.count) apps")
            Button("Choose apps") {
                appSelecting = true
            }
            Toggle("Blocking", systemImage: "swift", isOn: $blocking)
                .padding(.horizontal)
            Toggle("Hiding", systemImage: "swift", isOn: $hiding)
                .padding(.horizontal)
        }
        
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
        
        .onChange(of: hiding) { _, newValue in
            if newValue {
                startHiding()
            } else {
                stopHiding()
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
        //store.clearAllSettings()
    }
    
    func startHiding() {
        store.application.blockedApplications = appSelection.applications
    }
    
    func stopHiding() {
        store.application.blockedApplications = nil
    }
}

#Preview {
    ContentView()
}

struct AppSelectedGroupView: View {
    var title: String
    var groupID: String // ?
    @Binding var selection: FamilyActivitySelection
    @State var blockingType: BlockType = .normal
    @State var currentBlocking: BlockType = .normal
    @State private var isSelecting = false
    
    enum BlockType: Int {
        case normal, shield, frozen
        // Normal in type selection is "both", in current is "not block"
    }
    
    @inlinable func sysImgforSel(_ type: BlockType) -> String {
        type == blockingType ? "checkmark.circle.fill" : "circle.dotted"
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.systemGray6))
            VStack {
                HStack {
                    Text(title).font(.title3).bold()
                    Spacer()
                    Menu {
                        Button {
                            //
                        } label: { Label("Copy group ID", systemImage: "doc.on.doc") }
                        Button {
                            isSelecting = true
                        } label: { Label("Select apps", systemImage: "app.badge.checkmark") }
                        Menu {
                            Button { blockingType = .shield
                            } label: { Label("Shield (overlay)", systemImage: sysImgforSel(.shield)) }
                            Button { blockingType = .frozen
                            } label: { Label("Frozen (hidden)", systemImage: sysImgforSel(.frozen)) }
                            Button { blockingType = .normal
                            } label: { Label("Both available", systemImage: sysImgforSel(.normal)) }
                        } label: { Label("Block type", systemImage: "shield.lefthalf.filled.badge.checkmark") }
                        Button(role: .destructive) {
                            //
                        } label: { Label("Delete group", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
                Divider().offset(y: -4)
                HStack {
                    Image(systemName: "app.badge.checkmark.fill").foregroundColor(.gray)
                    Text("\(selection.applications.count) apps").foregroundColor(.gray)
                    Spacer()
                    Picker("", selection: $currentBlocking) {
                        Label("Normal", systemImage: "swift").tag(BlockType.normal)
                        if blockingType != .frozen {
                            Label("Shield", systemImage: "swift").tag(BlockType.shield)
                        }
                        if blockingType != .shield {
                            Label("Frozen", systemImage: "swift").tag(BlockType.frozen)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden().frame(width: blockingType == .normal ? 195 : 130)
                }
            }.padding(10)
        }
        .padding()
        
        .familyActivityPicker(
            isPresented: $isSelecting,
            selection: $selection
        )
        
        .onChange(of: blockingType) { _, newValue in
            if (
                newValue == .shield && currentBlocking == .frozen
            ) || (
                newValue == .frozen && currentBlocking == .shield
            ) { currentBlocking = .normal }
        }
    }
}
