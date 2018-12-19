//
//  Socket.swift
//  ActivityLogger
//
//  Created by Werner SEEGERS on 2018/12/19.
//  Copyright © 2018 Werner SEEGERS. All rights reserved.
//

import Cocoa

class Socket: WebSocketDelegate {
    
    var socket: WebSocket!
    
    enum messageKey {
        case LOGIN
        case IDLE
        case APP
    }
    
    
    init(host: String, port: Int) {
        
        print("Socket Init: http://\(host):\(port)")
        var request = URLRequest(url: URL(string: "http://\(host):\(port)")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        socket.write(string: "LOGIN,\(NSUserName())")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received text: \(text)")

    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    
    func message(key : messageKey, value : String){
       
        var message = ""
        
        switch key {
        case .LOGIN:
            message = "LOGIN"
        case .IDLE:
            message = "IDLE"
        case .APP:
            message = "APP"
        }
        
        message += ",\(value)"
        
        socket.write(string: message)
    }

}
