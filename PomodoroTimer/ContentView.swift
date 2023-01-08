//
//  ContentView.swift
//  PomodoroTimer
//
//  Created by cano on 2023/01/08.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var pomodoroViewModel: PomodoroViewModel
    
    init(pomodoroViewModel: PomodoroViewModel = PomodoroViewModel()) {
        self.pomodoroViewModel = pomodoroViewModel
    }
    
    var body: some View {
        VStack{
            Text("Pomodoro Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            GeometryReader{proxy in
                VStack(spacing: 15){
                    // MARK: Timer Ring
                    ZStack{
                        Circle()
                            .fill(.white.opacity(0.03))
                            .padding(-40)
                        
                        Circle()
                            .trim(from: 0, to: pomodoroViewModel.progress)
                            .stroke(.white.opacity(0.03),lineWidth: 80)
                        
                        // MARK: Shadow
                        Circle()
                            .stroke(Color.purple,lineWidth: 5)
                            .blur(radius: 15)
                            .padding(-2)
                        
                        Circle()
                            .fill(Color.black)
                        
                        Circle()
                            .trim(from: 0, to: pomodoroViewModel.progress)
                            .stroke(Color.purple.opacity(0.7),lineWidth: 10)
                        
                        // MARK: Knob
                        GeometryReader{proxy in
                            let size = proxy.size
                            
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 30, height: 30)
                                .overlay(content: {
                                    Circle()
                                        .fill(.white)
                                        .padding(5)
                                })
                                .frame(width: size.width, height: size.height, alignment: .center)
                            // MARK: Since View is Rotated Thats Why Using X
                                .offset(x: size.height / 2)
                                .rotationEffect(.init(degrees: pomodoroViewModel.progress * 360))
                        }
                        
                        Text(pomodoroViewModel.timerStringValue)
                            .font(.system(size: 45, weight: .light))
                            .rotationEffect(.init(degrees: 90))
                            .animation(.none, value: pomodoroViewModel.progress)
                    }
                    .padding(60)
                    .frame(height: proxy.size.width)
                    .rotationEffect(.init(degrees: -90))
                    .animation(.easeInOut, value: pomodoroViewModel.progress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    Button {
                        if pomodoroViewModel.isStarted{
                            pomodoroViewModel.stopTimer()
                            // MARK: Cancelling All Notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }else{
                            pomodoroViewModel.addNewTimer = true
                        }
                    } label: {
                        Image(systemName: !pomodoroViewModel.isStarted ? "timer" : "stop.fill")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background{
                                Circle()
                                    .fill(Color.purple)
                            }
                            .shadow(color: Color.purple, radius: 8, x: 0, y: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .padding()
        .background{
            Color.black
                .ignoresSafeArea()
        }
        .overlay(content: {
            ZStack{
                Color.black
                    .opacity(pomodoroViewModel.addNewTimer ? 0.25 : 0)
                    .onTapGesture {
                        pomodoroViewModel.hour = 0
                        pomodoroViewModel.minutes = 0
                        pomodoroViewModel.seconds = 0
                        pomodoroViewModel.addNewTimer = false
                    }
                
                NewTimerView()
                    .frame(maxHeight: .infinity,alignment: .bottom)
                    .offset(y: pomodoroViewModel.addNewTimer ? 0 : 400)
            }
            .animation(.easeInOut, value: pomodoroViewModel.addNewTimer)
        })
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if pomodoroViewModel.isStarted{
                pomodoroViewModel.updateTimer()
            }
        }
        .alert("Congratulations You did it hooray 🥳🥳🥳", isPresented: $pomodoroViewModel.isFinished) {
            Button("Start New",role: .cancel){
                pomodoroViewModel.stopTimer()
                pomodoroViewModel.addNewTimer = true
            }
            Button("Close",role: .destructive){
                pomodoroViewModel.stopTimer()
            }
        }
    }
    
    // MARK: New Timer Bottom Sheet
    @ViewBuilder
    func NewTimerView()->some View{
        VStack(spacing: 15){
            Text("Add New Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top,10)
            
            HStack(spacing: 15){
                Text("\(pomodoroViewModel.hour) hr")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 12, hint: "hr") { value in
                            pomodoroViewModel.hour = value
                        }
                    }
                
                Text("\(pomodoroViewModel.minutes) min")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "min") { value in
                            pomodoroViewModel.minutes = value
                        }
                    }
                
                Text("\(pomodoroViewModel.seconds) sec")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "sec") { value in
                            pomodoroViewModel.seconds = value
                        }
                    }
            }
            .padding(.top,20)
            
            Button {
                pomodoroViewModel.startTimer()
            } label: {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal,100)
                    .background{
                        Capsule()
                            .fill(Color.purple)
                    }
            }
            .disabled(pomodoroViewModel.seconds == 0)
            .opacity(pomodoroViewModel.seconds == 0 ? 0.5 : 1)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black)
                .ignoresSafeArea()
        }
    }
    
    // MARK: Reusable Context Menu Options
    @ViewBuilder
    func ContextMenuOptions(maxValue: Int,hint: String,onClick: @escaping (Int)->())->some View{
        ForEach(0...maxValue,id: \.self){value in
            Button("\(value) \(hint)"){
                onClick(value)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

