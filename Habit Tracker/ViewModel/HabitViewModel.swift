//
//  HabitViewModel.swift
//  Habit Tracker
//
//  Created by Byron Mejia on 5/26/22.
//

import SwiftUI
import CoreData

class HabitViewModel: ObservableObject {
    // MARK: New Habit Properties

    @Published var addNewHabit = false
    @Published var title = ""
    @Published var habitColor = "Card-1"
    @Published var weekDays = [String]()
    @Published var isRemainderOn = false
    @Published var remainderTex = ""
    @Published var remainderDate = Date()
    
    // MARK: Remainder Time Picker
    
    @Published var showTimePicker = false
    
    // MARK: Editing Habit
    
    @Published var editHabit: Habit?
    
    // MARK: Notification Access Status
    
    @Published var notificationAccess = false
    
    init() {
        requestNotificationAccess()
    }
    
    private func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    // MARK: Adding Habit to Database
    
    func addHabbit(context: NSManagedObjectContext) async -> Bool {

        // MARK: Editing Data

        var habit: Habit!
        if let editHabit = editHabit {
            habit = editHabit
            
            // Removing All Pending Notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationsIDs ?? [])
        } else {
            habit = Habit(context: context)
        }

        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = isRemainderOn
        habit.remainderText = remainderTex
        habit.notificationDate = remainderDate
        habit.notificationsIDs = []
        
        if isRemainderOn {
            // MARK: Scheduling Notifications
            if let ids = try? await scheduleNotification() {
                habit.notificationsIDs = ids
                if let _ = try? context.save() {
                    return true
                }
            }
        } else {
            // MARK: Adding Data
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Adding Notifications
    
    func scheduleNotification() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Habit Remainder"
        content.subtitle = remainderTex
        content.sound = UNNotificationSound.default
        
        // Schedule Ids
        var notificationsIDs = [String]()
        let calendar = Calendar.current
        let weekDaySymbols: [String] = calendar.weekdaySymbols
        
        // MARK: Scheduling Notification
        for weekDay in weekDays {
            // Unique ID For Each Notification
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: remainderDate)
            let min = calendar.component(.minute, from: remainderDate)
            let day = weekDaySymbols.firstIndex { currentDay in
                return currentDay == weekDay
            } ?? -1
            
            // MARK: Since Week Day Starts from 1-7
            // Thus Adding +1 to Index
            if day != -1 {
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                
                // MARK: Thus this will Trigger Notification on Each
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // MARK: Notification Request
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                
                // Adding ID
                notificationsIDs.append(id)
            }
        }
        return notificationsIDs
    }
    
    // MARK: Erasing Content
    
    func resetDate() {
        title = ""
        habitColor = "Card-1"
        weekDays = []
        isRemainderOn = false
        remainderTex = ""
        remainderDate = Date()
        editHabit = nil
    }
    
    // MARK: Deleting Habit From DataBase
    
    func deleteHabit(context: NSManagedObjectContext) -> Bool{
        if let editHabit = editHabit {
            if editHabit.isRemainderOn {
                // Removing All Pending Notifications
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationsIDs ?? [])
            }
            context.delete(editHabit)
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Restoring Edit Data
    
    func restoreEditData() {
        if let editHabit = editHabit {
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? "Card-1"
            weekDays = editHabit.weekDays ?? []
            isRemainderOn = editHabit.isRemainderOn
            remainderTex = editHabit.remainderText ?? ""
            remainderDate = editHabit.notificationDate ?? Date()
        }
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
