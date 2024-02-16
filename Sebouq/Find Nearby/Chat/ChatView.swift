//
//  ChatView.swift
//  Find Nearby
//
//  Created by Norah w on 2023/8/21.
//

import SwiftUI
import QuickLook

struct ChatView: View {
    @EnvironmentObject var mc: MCManager
    
    @State var editMode: EditMode = .inactive
    @State var showSheet = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                if mc.connectedPeers.isEmpty {
                    EmptyChatNotice()
                } else {
                    ChatList()
                        .environmentObject(mc)
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("الأصدقاء")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !mc.connectedPeers.isEmpty && editMode == .active {
                        Button("Cancel", role: .cancel) {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !mc.connectedPeers.isEmpty && editMode == .inactive {
                        menuButton
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showSheet) {
                NavigationView {
                    ChatFiles()
                        .navigationTitle("Received files")
                        .toolbar {
                            Button("Done") {
                                showSheet = false
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    var menuButton: some View {
        
        Menu {
            Button("Select", systemImage: "checkmark.circle") {
                withAnimation {
                    editMode = .active
                }
            }
            Button("Received files", systemImage: "folder") {
                showSheet = true
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .imageScale(.large)
    }
}

struct EmptyChatNotice: View {
    var body: some View {
        ZStack {
            Image("back")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            VStack {
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                Text("No active chats")
                    .font(.largeTitle).bold()
                    .padding(.leastNormalMagnitude)
            }
            .padding()

        }
    }
}
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(MCManager())
    }
}
