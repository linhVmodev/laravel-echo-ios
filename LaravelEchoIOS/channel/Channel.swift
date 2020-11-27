//
//  Channel.swift
//  laravel-echo-ios
//
//  Created by valentin vivies on 21/07/2017.
//

import Foundation
import SocketIO


/// This class represents a basic channel.
public class Channel: IChannel {

    
    /// The Echo options.
    public var options: [String: Any]

    
    /// Create new Channel
    ///
    /// - Parameter options: options
    public init (options: [String: Any]){
        self.options = options
    }

    
    /// Listen for an event on the channel instance.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    /// - Returns: the channel itself
    @discardableResult public func listen(event: String, callback: @escaping NormalCallback) -> IChannel {
        return self
    }

    
    /// Listen for an event on the channel instance.
    ///
    /// - Parameter callback: callback
    /// - Returns: the channel itself
    public func notification(callback: @escaping NormalCallback) -> IChannel {
        return self.listen(event: ".Illuminate.Notifications.Events.BroadcastNotificationCreated", callback: callback)
    }

    
    /// Listen for a whisper event on the channel instance.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    /// - Returns: the channel itself
    public func listenForWhisper(event: String, callback: @escaping NormalCallback) -> IChannel {
        return self.listen(event: "client-" + event, isFormat: false, callback: callback)
    }

    
    /// Unsubscribe from channel and ubind event callbacks.
    public func unsubscribe(){

    }

    
    /// Subscribe to a Socket.io channel.
    public func subscribe(){

    }

}
