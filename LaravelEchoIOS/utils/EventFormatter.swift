//
//  EventFormatter.swift
//  laravel-echo-ios
//
//  Created by valentin vivies on 21/07/2017.
//

import Foundation


/// Event name formatter
public class EventFormatter {
    
    
    /// Event namespace.
    public var namespace = ""
    
    
    /// Create a new class instance.
    ///
    /// - Parameter namespace: namespce
    public init(namespace: String? = ""){
        self.setNamespace(value: namespace!)
    }
    
    
    /// Format the given event name.
    ///
    /// - Parameter event: event name
    /// - Returns: formated event name
    public func format(event: String) -> String {
        var e : String = ""
        if(!(event.hasPrefix("\\") || event.hasPrefix("."))){
            e = self.namespace + "." + event
        } else {
            let index = event.index(event.startIndex, offsetBy: 1)
            return String(event[index...])
        }
        return e.replacingOccurrences(of: ".", with: "\\")
    }
    
    
    /// Set the event namespace.
    ///
    /// - Parameter value: namespace
    public func setNamespace(value: String? = "") {
        if let wrap = value {
            self.namespace = wrap;
        }
    }
    
}
