//
//  HabitTrackerApp.swift
//  Habit Tracker
//
//  Created by Byron Mejia on 5/25/22.
//

import SwiftUI

@main
struct Habit_TrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
