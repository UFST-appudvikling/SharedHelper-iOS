//
//  MixpanelClient.swift
//
//
//  Created by Nicolai Dam on 17/10/2022.
//

import Mixpanel

/// A trigger that causes analytics events to be tracked
/// Events are not app specific, therefore this enum should be used in all apps
/// EventTriggers can be added if needed
public enum EventTrigger {
    case viewAppear
    case onTap(String)
    case willTerminate
    case action(String)
    case log(LogInput)
}

public struct LogInput {
    let message: String
    let identifier: String
    
    public init(message: String, identifier: String) {
        self.message = message
        self.identifier = identifier
    }
}

/// Generic Mixpanel client
/// Can easiliy fit into different projects since EventTriggers are universal and custom properties can be set when needed
/// This client can be mocked if needed and is therefore easy to test in context to the rest of the application logic
public struct MixPanelClient {
    
    /// Initialising MixPanel
    /// - Parameters:
    ///   - mixpanelHash: unique mixpanel hash for the given project
    /// - Returns: Void
    public var initialise: (_ mixpanelHash: String) -> Void
    
    /// Tracks MixPanel event
    /// The mixpanel client should initialized before this method is used
    /// - Parameters:
    ///   - event: type of event that triggered the tracking
    ///   - screenIdentifier: identifier for the screen
    ///   - extraProperties: Extra event properties where key is the property key and the second one is the value.
    /// - Returns: Void
    /// - Example: enum example to be used for screenIdentifier and extraProperties
    /// ````
    /// public struct MixPanelString {
    ///    public enum ScreenIdentifier: String, RawRepresentable {
    ///        case screen1
    ///        case screen2
    ///        case screen3
    ///    }
    ///
    ///    public enum PropertyKey: String {
    ///        case key1 = "Key1"
    ///        case key2 = "Key2"
    ///    }
    ///
    ///    public enum PropertyValue: String, RawRepresentable {
    ///        case value1
    ///        case value2
    ///    }
    ///
    ///    public enum OnTapValue: String, RawRepresentable {
    ///        case button1
    ///        case button2
    ///    }
    ///}
    /// ````
    public var trackEvent: (TrackEventInput) -> Void
    public var registerSuperProperty: (_ key: String, _ value: String) -> Void
}

public struct TrackEventInput {
    public let event: EventTrigger
    public let screenIdentifier: String?
    public let extraProperties: [String: AnyObject]?
    
    public init(event: EventTrigger, screenIdentifier: String? = nil, extraProperties: [String : AnyObject]? = nil) {
        self.event = event
        self.screenIdentifier = screenIdentifier
        self.extraProperties = extraProperties
    }
}

public extension MixPanelClient {
    static var live = Self(
        initialise: {
            Mixpanel.initialize(token: $0, trackAutomaticEvents: true)
        },
        trackEvent: { input in
            
            let event = input.event
            let screenIdentifier = input.screenIdentifier
            let extraProperties = input.extraProperties
            
            var eventName: String
            
            
            var properties: [String: MixpanelType] = [:]
            
            switch event {
            case .viewAppear:
                eventName = "View Page"
                
            case .onTap(let value):
                eventName = "On Tap \(value)"
                
            case .willTerminate:
                eventName = "App Terminated"
            case .action(let value):
                eventName = "\(value)"
            case .log(let input):
                eventName = "Log"
                properties["LogMessage"] = input.message
                properties["LogIdentifier"] = input.identifier
            }
            
            if let screenIdentifier = screenIdentifier {
                properties["ScreenIdentifier"] = screenIdentifier
            }
            
            if let extraProperties = extraProperties {
                for (key, value) in extraProperties {
                    if key == "ScreenIdentifier" {
                        assertionFailure("Key for extra property should not be ScreenIdentifier since it is a reserved key")
                    }
                    if let castedValue = value as? MixpanelType {
                        properties[key] = castedValue
                    } else {
                        assertionFailure("Please send MixPanelTypes")
                    }
                }
            }
            
            Mixpanel.mainInstance().track(
                event: eventName, properties: properties
            )
        },
        registerSuperProperty: { key, value in
            Mixpanel.mainInstance().registerSuperProperties([key: value])
        }
    )
}

public extension MixPanelClient {
    static var emptyClient = Self(initialise: { _ in }, trackEvent: { _ in }, registerSuperProperty: { _, _ in})
}

