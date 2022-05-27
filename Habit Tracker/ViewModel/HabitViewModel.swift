//
//  HabitViewModel.swift
//  Habit Tracker
//
//  Created by Byron Mejia on 5/26/22.
//

import SwiftUI

class HabitViewModel: ObservableObject {

    @Published var addNewHabit = false
    
    @Published var title = ""
    @Published var habitColor = "Card-1"
    @Published var weekDays = [String]()
    @Published var isRemainderOn = false
    @Published var remainderTex = ""
    @Published var remainderDate = Date()
    
    
}

