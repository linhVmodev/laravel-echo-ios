//
//  SocketIOChannel.swift
//  laravel-echo-ios
//
//  Created by valentin vivies on 21/07/2017.
//

import Foundation
import SocketIO


/// This class represents a Socket.io channel.
public class SocketIoChannel: Channel {
    
    
    /// The Socket.io client instance.
    public var socket: SocketIOClient
    
    
    /// The name of the channel.
    public var name: String

    
    /// Channel auth options.
    public var auth: [String: Any]
    
    
    /// The event formatter.
    public var eventFormatter: EventFormatter
    
    
    /// The event callbacks applied to the channel.
    public var events : [String: [NormalCallback]]

    
    /// Create a new class instance.
    ///
    /// - Parameters:
    ///   - socket: the socket instance
    ///   - name: the channel name
    ///   - options: options for the channel
    public init(socket: SocketIOClient, name: String, options: [String: Any]){
        self.name = name
        self.socket = socket
        self.events = [:]

        var namespace = ""
        if let wrapperNamespace = options["namespace"] as? String{
            namespace = wrapperNamespace
        }

        self.auth = [:]
        if let wrapperAuth = options["auth"] as? [String: Any]{
            self.auth = wrapperAuth
        }

        self.eventFormatter = EventFormatter(namespace: namespace)

        super.init(options: options)

        self.subscribe()
        self.configureReconnector()
    }

    
    /// Subscribe to a Socket.io channel.
    public override func subscribe(){
        let data = [["channel": self.name, "auth": self.auth]]
        self.socket.emit("subscribe", with : data)
    }

    
    /// Unsubscribe from channel and ubind event callbacks.
    public override func unsubscribe(){
        self.unbind()
        let data = [["channel": self.name, "auth": self.auth]]
        self.socket.emit("unsubscribe", with: data)
    }

    
    /// Listen for an event on the channel instance.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    /// - Returns: the channel itself
    public override func listen(event: String, isFormat: Bool = true, callback: @escaping NormalCallback) -> IChannel{
        let eventString = isFormat ? self.eventFormatter.format(event: event) : event
        self.on(event: eventString, callback: callback)
        return self
    }

    
    /// Bind the channel's socket to an event and store the callback.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    public func on(event: String, callback: @escaping NormalCallback){

        func listener(data: [Any], ack: SocketAckEmitter){
            if let channel = data[0] as? String {
                if(self.name == channel){
                    callback(data, ack)
                }
            }
        }

        self.socket.on(event, callback: listener)
        self.bind(event: event, callback: listener)
    }

    
    /// Attach a 'reconnect' listener and bind the event.
    public func configureReconnector(){

        func listener(event: [Any], _ack: SocketAckEmitter){
            self.subscribe()
        }

        self.socket.on("reconnect", callback: listener)
        self.bind(event: "reconnect", callback: listener)
    }

    
    /// Bind the channel's socket to an event and store the callback.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    public func bind(event: String, callback: @escaping NormalCallback){
        if(self.events[event] == nil){
            self.events[event] = []
        }
        self.events[event]!.append(callback)
    }

    
    /// Unbind the channel's socket from all stored event callbacks.
    public func unbind(){
        for (key, _) in self.events {
            self.events[key] = nil
        }
        self.socket.removeAllHandlers()
    }
    
}
