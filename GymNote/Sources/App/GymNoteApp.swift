//
//  GymNoteApp.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import App
import SwiftUI

@main
struct GymNoteApp: App {
    var body: some Scene {
        WindowGroup {
          AppFeature.MainView(store: .init(initialState: .init(), reducer: AppFeature.init))
        }
    }
}
