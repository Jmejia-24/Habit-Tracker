//
//  Home.swift
//  Habit Tracker
//
//  Created by Byron Mejia on 5/25/22.
//

import SwiftUI

struct Home: View {
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath:\Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var habits: FetchedResults<Habit>
    @StateObject var viewModel: HabitViewModel = .init()
    
    var body: some View {
        VStack (spacing: 0) {
            Text("Habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Button {
                        viewModel.addNewHabit.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack (spacing: 15) {
                    Button {
                        
                    } label: {
                        Label {
                            Text("New Habit")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                        .font(.callout.bold())
                        .foregroundColor(.white)
                        
                    }
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .sheet(isPresented: $viewModel.addNewHabit) {
                        viewModel.resetDate()
                    } content: {
                        AddNewHabit()
                            .environmentObject(viewModel)
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
