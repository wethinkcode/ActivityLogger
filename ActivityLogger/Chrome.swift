//
//  Chrome.swift
//  ActivityLogger
//
//  Created by Werner SEEGERS on 2018/12/18.
//  Copyright © 2018 Werner SEEGERS. All rights reserved.
//

import Cocoa

class Chrome: NSObject {
    
//    let chromeObject : AnyObject
//
//    override init() {
//        self.chromeObject = SBApplication.init(bundleIdentifier: "com.google.Chrome")!
//        super.init()
//    }
    
    static public func getChrome() -> AnyObject {
        return SBApplication.init(bundleIdentifier: "com.google.Chrome")! as AnyObject
    }
    
    static public func getWindows() -> [AnyObject] {
        return Chrome.getChrome().windows() as [AnyObject]
    }
    
    static public func getActiveWindow() -> AnyObject {
        return Chrome.getWindows()[0]
    }
    
    static public func getActiveTab() -> AnyObject {
        return Chrome.getActiveWindow().activeTab
    }
    
    static public func getActiveUrl() -> String {
        return Chrome.getActiveTab().url
    }
    
    static public func getHostName() -> String {
        let urlString = Chrome.getActiveUrl()
        let url = URL(string: urlString)
        
        return (url?.host)!
    }

}
