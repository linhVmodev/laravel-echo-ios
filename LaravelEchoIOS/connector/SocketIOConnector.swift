//
// Created by valentin vivies on 21/07/2017.
//

import Foundation
import SocketIO


/// This class creates a connnector to a Socket.io server.
public class SocketIOConnector: IConnector {

    
    /// The Socket.io connection instance.
    public var socket: SocketIOClient?

    
    /// Default connector options.
    public var _defaultOptions: [String: Any] = [ "auth": ["headers": []], "authEndpoint": "/broadcasting/auth", "broadcaster": "socket.io", "host": "", "key": "", "namespace": "App.Events"]

    
    /// Connector options.
    public var options: [String: Any]

    
    /// All of the subscribed channels.
    public var channels: [String: IChannel]

    
    /// Create a new class instance.
    ///
    /// - Parameter options: options
    public init(options: [String: Any]){
        self.socket = nil
        self.options = options
        self.channels = [:]
        //self.setOptions(options: options)
        self.connect()
    }

    
    /// Merge the custom options with the defaults.
    ///
    /// - Parameter options: options
    public func setOptions(options: [String: Any]){
        self.options =  self.mergeOptions(options: options)
    }

    
    /// Create a fresh Socket.io connection.
    public func connect(){
        if let url = self.options["host"] as? String {
            let nurl: URL! = URL(string: url)
            let socketConfig: SocketIOClientConfiguration = [.log(true)]
            let manager = SocketManager(socketURL: nurl, config: socketConfig)
            self.socket = manager.defaultSocket
            self.socket?.connect(timeoutAfter: 5, withHandler: {
                print("ERROR")
            })
        }
    }
    
    
    /// Add other handler type
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    public func on(event: String, callback: @escaping NormalCallback){
        self.socket!.on(event, callback: callback)
    }

    
    /// Listen for an event on a channel instance.
    ///
    /// - Parameters:
    ///   - name: channel name
    ///   - event: event name
    ///   - callback: callback
    /// - Returns: the channel
    public func listen(name : String, event: String, callback: @escaping NormalCallback) -> IChannel{
        return self.channel(name: name).listen(event: event, callback: callback)
    }

    
    /// Get a channel instance by name.
    ///
    /// - Parameter name: channel name
    /// - Returns: the channel
    public func channel(name: String) -> IChannel{
        if(self.channels[name] == nil){
            let socket: SocketIOClient! = self.socket
            self.channels[name] = SocketIoChannel(
                socket: socket, name: name, options: self.options
            )
        }
        return self.channels[name]!
    }

    
    /// Get a private channel instance by name.
    ///
    /// - Parameter name: channel name
    /// - Returns: the private channel
    public func privateChannel(name: String) -> IPrivateChannel{
        if(self.channels["private-" + name] == nil){
            let socket: SocketIOClient! = self.socket
            self.channels["private-" + name] = SocketIOPrivateChannel(
            socket: socket, name: "private-" + name, options: self.options
            )
        }
        return self.channels["private-" + name]! as! IPrivateChannel
    }

    
    /// Get a presence channel instance by name.
    ///
    /// - Parameter name: channel name
    /// - Returns: the presence channel
    public func presenceChannel(name: String) -> IPresenceChannel{
        if(self.channels["presence-" + name] == nil){
            let socket: SocketIOClient! = self.socket
            self.channels["presence-" + name] = SocketIOPresenceChannel(
            socket: socket, name: "presence-" + name, options: self.options
            )
        }
        return self.channels["presence-" + name]! as! IPresenceChannel
    }

    
    /// Leave the given channel.
    ///
    /// - Parameter name: channel name
    public func leave(name : String){
        let channels: [String] = [name, "private-" + name, "presence-" + name];
        for(name) in channels{
            if let c = self.channels[name] {
                c.unsubscribe()
                self.channels[name] = nil
            }
        }
    }

    
    /// Get the socket_id of the connection.
    ///
    /// - Returns: the socket id
    public func socketId() -> String {
        if let socket: SocketIOClient = self.socket{
            return socket.sid
        }
        return ""
    }

    
    /// Disconnect from the Echo server.
    public func disconnect(){
        let socket: SocketIOClient! = self.socket
        socket.disconnect()
    }
    
    
    /// Merge options with default
    ///
    /// - Parameter options: the options
    /// - Returns: merged options
    public func mergeOptions(options : [String: Any]) -> [String: Any]{
        var def = self._defaultOptions
        for (k, v) in options{
            def[k] = v
        }
        return def
    }

}
