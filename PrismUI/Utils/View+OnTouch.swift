//
//  View+OnTouch.swift
//  PrismUI
//
// From: Hacking With Swift https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-the-location-of-a-tap-inside-a-view

import SwiftUI

// Our UIKit to SwiftUI wrapper view
struct TouchLocatingView: NSViewRepresentable {
    // The types of touches users want to be notified about
    struct TouchType: OptionSet {
        let rawValue: Int

        static let started = TouchType(rawValue: 1 << 0)
        static let moved = TouchType(rawValue: 1 << 1)
        static let ended = TouchType(rawValue: 1 << 2)
        static let all: TouchType = [.started, .moved, .ended]
    }

    // A closer to call when touch data has arrived
    var onUpdate: (CGPoint) -> Void

    // The list of touch types to be notified of
    var types = TouchType.all

    // Whether touch information should continue after the user's finger has left the view
    var limitToBounds = true

    func makeNSView(context: Context) -> TouchLocatingNSView {
        // Create the underlying UIView, passing in our configuration
        let view = TouchLocatingNSView()
        view.onUpdate = onUpdate
        view.touchTypes = types
        view.limitToBounds = limitToBounds
        return view
    }

    func updateNSView(_ uiView: TouchLocatingNSView, context: Context) {
    }

    // The internal UIView responsible for catching taps
    class TouchLocatingNSView: NSView {
        // Internal copies of our settings
        var onUpdate: ((CGPoint) -> Void)?
        var touchTypes: TouchLocatingView.TouchType = .all
        var limitToBounds = true

        // Our main initializer, making sure interaction is enabled.
        override init(frame: CGRect) {
            super.init(frame: frame)
        }

        // Just in case you're using storyboards!
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        // Triggered when a mouse touches.
        override func mouseDown(with event: NSEvent) {
            let point = event.locationInWindow
            let location = convert(point, from: nil)
            send(location, forEvent: .started)
            super.mouseDown(with: event)
        }

        // Triggered when an existing mouse moves.
        override func mouseDragged(with event: NSEvent) {
            let point = event.locationInWindow
            let location = convert(point, from: nil)
            send(location, forEvent: .moved)
            super.mouseDragged(with: event)
        }

        // Triggered when the mouse is not clicked.
        override func mouseUp(with event: NSEvent) {
            let point = event.locationInWindow
            let location = convert(point, from: nil)
            send(location, forEvent: .ended)
            super.mouseUp(with: event)
        }

        // Send a touch location only if the user asked for it
        func send(_ location: CGPoint, forEvent event: TouchLocatingView.TouchType) {
            guard touchTypes.contains(event) else {
                return
            }

            if limitToBounds == false || bounds.contains(location) {
                onUpdate?(CGPoint(x: round(location.x), y: round(location.y)))
            }
        }
    }
}

// A custom SwiftUI view modifier that overlays a view with our UIView subclass.
struct TouchLocater: ViewModifier {
    var type: TouchLocatingView.TouchType = .all
    var limitToBounds = true
    let perform: (CGPoint) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(
                TouchLocatingView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
            )
    }
}

// A new method on View that makes it easier to apply our touch locater view.
extension View {
    func onTouch(type: TouchLocatingView.TouchType = .all, limitToBounds: Bool = true, perform: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
    }
}
