//
//  HabitViewModel.swift
//  Habit Tracker
//
//  Created by Byron Mejia on 5/26/22.
//

import SwiftUI
import CoreData

class HabitViewModel: ObservableObject {

    @Published var addNewHabit = false
    
    @Published var title = ""
    @Published var habitColor = "Card-1"
    @Published var weekDays = [String]()
    @Published var isRemainderOn = false
    @Published var remainderTex = ""
    @Published var remainderDate = Date()
    
    @Published var showTimePicker = false
    
    
    func addHabbit(context: NSManagedObjectContext) -> Bool {
        let habit = Habit(context: context)
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = isRemainderOn
        habit.remainderText = remainderTex
        habit.notificationDate = remainderDate
        habit.notificationsIDs = []
        
        if isRemainderOn {
            // MARK: Scheduling Notifications
        } else {
            // MARK: Adding Data
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }

    // MARK: Erasing Content
    
    func resetDate() {
        title = ""
        habitColor = "Card-1"
        weekDays = []
        isRemainderOn = false
        remainderTex = ""
        remainderDate = Date()
    }
    
    // MARK: Done Button Status
    func doneStatus() -> Bool {
        let remainderStatus = isRemainderOn ? remainderTex == "" : false
        
        if title == "" || weekDays.isEmpty || remainderStatus {
            return false
        }
        return true
    }
}

