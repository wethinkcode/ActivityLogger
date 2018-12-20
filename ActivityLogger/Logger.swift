//
//  Logger.swift
//  ActivityLogger
//
//  Created by Werner SEEGERS on 2018/12/18.
//  Copyright © 2018 Werner SEEGERS. All rights reserved.
//

import Cocoa

class Logger: NSObject {
    
    // Config
    private let pollDelay : Int
    
    // State
    private var idleState : Bool
    
    private let observer : AppChangeObserver
    private let socket : Socket
    
    private var currentApp : String
    
    init(observer: AppChangeObserver, socket : Socket){
        
        self.pollDelay = 1
        
        self.idleState = false
        
        self.observer = observer
        self.socket = socket
        self.currentApp = "None"
        
        super.init()
    }
    
    public func start(){
        Timer.scheduledTimer(withTimeInterval: TimeInterval(pollDelay), repeats: true, block: logActivity)
    }
    
    private func logActivity(_ : Timer){
        if (currentApp) != observer.activeApp{
//            print("App Changed")
            socket.message(key: .APP, value: observer.activeApp)
            currentApp = observer.activeApp
        }
        
//        print(getIdleTime())
        let isNowIdle = isIdle()
        if isNowIdle != idleState {
            socket.message(key: .IDLE, value: "_")
            idleState = isNowIdle
        }
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
    
    public func isIdle() -> Bool { return getIdleTime() >= 1 }

}
