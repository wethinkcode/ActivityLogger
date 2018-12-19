//
//  Logger.swift
//  ActivityLogger
//
//  Created by Werner SEEGERS on 2018/12/18.
//  Copyright © 2018 Werner SEEGERS. All rights reserved.
//

/*
 
 
 Start a timer every second poll
 --> Get App Name
 --> Idle Time
 --> if App is Chome
    --> Open Tab
 On Change Post
 
 */

import Cocoa

class Logger: NSObject {
    
    // Config
    private let interval : Int
    private let pollDelay : Int
    private var cycle : Int
    private let idleThreshold : Int
    
    // State
    private var currentTime : Int
    
    private var idleChangeTime : Int
    private var idleState : Bool
    
    private let appManager : AppManager
    private var observer : AppChangeObserver
    
    init(interval: Int, observer: AppChangeObserver, pollDelay : Int = 1, idleThreshold : Int = 30){
        
        self.interval = interval
        self.pollDelay = pollDelay
        self.cycle = 0
        self.idleThreshold = idleThreshold
        
        self.currentTime = Int(NSDate.init().timeIntervalSince1970)
        
        self.idleState = false
        self.idleChangeTime = 0
        
        self.appManager = AppManager(lostFocusThreshold: 5, gainFocusThreshold: 5)
        self.observer = observer
        
        super.init()
    }
    
    public func start(){
        cycle = interval - Int(NSDate.init().timeIntervalSince1970) % interval
        if (cycle == 0){
            cycle = interval
        }
        Timer.scheduledTimer(withTimeInterval: TimeInterval(pollDelay), repeats: true, block: logActivity)
        
    }
    
    private func logActivity(_ : Timer){
        self.currentTime = Int(NSDate.init().timeIntervalSince1970)
        pollIdle()
        appManager.logFocus(currentApp: observer.activeApp, currentTime: currentTime)
    }
    
    private func pollIdle(){
        let idleTime = getIdleTime()
//        print("idleTime : \(idleTime)")
        
        switch idleState{
        case false:
            if idleTime > idleThreshold{
                idleChangeTime = currentTime - idleThreshold
                postIdle(time: idleChangeTime)
                idleState = true
            }
        case true:
            if idleTime < 2{
                idleChangeTime = currentTime
                postIdle(time: idleChangeTime)
                idleState = false
            }
        }
    }
    
    private func postIdle(time : Int){
        print("Idle Change At : \(time)")
    }
    
    
    public func getIdleTime() -> Int{
        
        let ioregToAwk = Pipe()
        let ioreg = Process()
        ioreg.launchPath = "/usr/sbin/ioreg"
        ioreg.arguments = ["-c", "IOHIDSystem"];
        ioreg.standardOutput = ioregToAwk;
        
        ioreg.launch()
        
        let awkOut = Pipe()
        let awk = Process()
        awk.standardInput = ioregToAwk;
        awk.launchPath = "/usr/bin/awk";
        awk.arguments = ["/HIDIdleTime/ {print int($NF/1000000000); exit}"];
        awk.standardOutput = awkOut;
        
        awk.launch()
        
        let data = awkOut.fileHandleForReading.readDataToEndOfFile()
        let stringOut = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
        
        return (stringOut?.integerValue ?? 0)
    }
    
}

private class AppManager{
    
    public var focusApp : String
    public var startTime : Int
    public var lostFocusCounter : Int
    public var lostFocusThreshold : Int
    
    public var nextApp : String
    public var gainFocusCounter : Int
    public var gainFocusThreshold : Int
    
    public var currentTime : Int
    
    init (lostFocusThreshold : Int, gainFocusThreshold : Int){
        self.focusApp = "None"
        self.startTime = 0
        self.lostFocusCounter = 0
        self.lostFocusThreshold = lostFocusThreshold
        
        self.nextApp = "None"
        self.gainFocusCounter = 0
        self.gainFocusThreshold = gainFocusThreshold
        
        self.currentTime = 0
    }
    
    public func logFocus(currentApp : String, currentTime : Int) {
//        print(currentApp)
//        print("Current App : \(focusApp)-\(lostFocusCounter)")
//        print("Next App : \(nextApp)-\(gainFocusCounter)")
        self.currentTime = currentTime
        print(self.currentTime)
        if focusApp == currentApp{
            lostFocusCounter = 0
            return
        }
        if focusApp == "None"{
            changeFocus(currentApp: currentApp)
        } else if lostFocusCounter == lostFocusThreshold {
            post()
            focusApp = "None"
            nextApp = currentApp
        } else {
            lostFocusCounter += 1
        }
    }
    
    private func changeFocus(currentApp : String){
        switch nextApp == currentApp{
        case true:
            if (gainFocusCounter >= gainFocusThreshold){
                print(gainFocusCounter)
                focusApp = currentApp
                startTime = currentTime - gainFocusCounter
                lostFocusCounter = 0
                gainFocusCounter = 1
            } else {
                gainFocusCounter += 1
            }
        case false:
            gainFocusCounter = 1
            nextApp = currentApp
        }
    }
    
    private func post(){
//        print (lostFocusCounter)
        print("\(focusApp): \(startTime) -> \(currentTime - lostFocusCounter)")
    }
    
}


//        let urlString = "http://endpoint.wethinkcode.co.za:4000/users/\(userName)/\(nextApp)"
//        let url = URL(string: urlString)!
//        print(url)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        URLSession.shared.dataTask(with: request).resume()
