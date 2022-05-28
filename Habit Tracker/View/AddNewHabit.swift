//
//  AddNewHabit.swift
//  Habit Tracker
//
//  Created by Byron Mejia on 5/26/22.
//

import SwiftUI

struct AddNewHabit: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.self) var env
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                TextField("Title", text: $viewModel.title)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                
                //MARK: Habit Color Picker
                
                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) { index in
                        let color = "Card-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == viewModel.habitColor {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                withAnimation {
                                    viewModel.habitColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                VStack (alignment: .leading, spacing: 6) {
                    Text("Frecuency")
                        .font(.callout.bold())
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack (spacing: 10) {
                        ForEach (weekDays, id: \.self) { day in
                            let index = viewModel.weekDays.firstIndex { value in
                                return value == day
                            } ?? -1
                            
                            Text(day.prefix(2))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index != -1 ? Color(viewModel.habitColor) : Color("TFBG").opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            viewModel.weekDays.remove(at: index)
                                        } else {
                                            viewModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 15)
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                HStack {
                    VStack (alignment: .leading, spacing: 6) {
                        Text("Remainder")
                            .fontWeight(.semibold)
                        
                        Text("Just notification")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $viewModel.isRemainderOn) {
                        
                    }
                    .labelsHidden()
                }
                
                HStack (spacing: 12) {
                    Label {
                        Text(viewModel.remainderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .onTapGesture {
                        withAnimation {
                            viewModel.showTimePicker.toggle()
                        }
                    }
                    
                    TextField("Remainder Text", text: $viewModel.remainderTex)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .frame(height: viewModel.isRemainderOn ? nil : 0)
                .opacity(viewModel.isRemainderOn ? 1 : 0)
                
            }
            .animation(.easeInOut, value: viewModel.isRemainderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.editHabit != nil ? "Edit Habit" : "Add Habit")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                }
                
                // MARK: Delete Button
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if viewModel.deleteHabit(context: env.managedObjectContext)  {
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(viewModel.editHabit == nil ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Task {
                            if await viewModel.addHabbit(context: env.managedObjectContext) {
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.white)
                    .disabled(!viewModel.doneStatus())
                    .opacity(viewModel.doneStatus() ? 1 : 0.6)
                    
                }
            }
        }
        .overlay {
            if viewModel.showTimePicker {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.showTimePicker.toggle()
                            }
                        }
                    
                    DatePicker.init("", selection: $viewModel.remainderDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("TFBG"))
                        }
                        .padding()
                }
            }
        }
    }
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
