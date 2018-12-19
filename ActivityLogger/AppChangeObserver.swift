//
//  Observer.swift
//  ActivityLogger
//
//  Created by Werner SEEGERS on 2018/12/18.
//  Copyright © 2018 Werner SEEGERS. All rights reserved.
//

import Cocoa

class AppChangeObserver: NSObject {
    
    public private(set) var activeApp : String
    
    override init (){
        
        self.activeApp = "Finder"
        super.init()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.appChangeHandler), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        print("Observer Init")
    }

    @objc private func appChangeHandler(notification : NSNotification) -> Void{
        
        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
        self.activeApp = app.localizedName!
    }
    
    
}
