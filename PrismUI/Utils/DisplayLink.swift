//
//  DisplayLink.swift
//  PrismUI
//
//  Created by timdonnelly, edited by ErrorErrorError
//
//  BSD 2-Clause License
//
//  Copyright (c) 2019, Tim Donnelly
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import Foundation
import Combine


// A publisher that emits new values when the system is about to update the display.
public final class DisplayLink: Publisher {
    public typealias Output = Frame
    public typealias Failure = Never

    private let platformDisplayLink: PlatformDisplayLink

    private var subscribers: [CombineIdentifier:AnySubscriber<Frame, Never>] = [:] {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            platformDisplayLink.isPaused = subscribers.isEmpty
        }
    }

    fileprivate init(platformDisplayLink: PlatformDisplayLink) {
        dispatchPrecondition(condition: .onQueue(.main))
        self.platformDisplayLink = platformDisplayLink
        self.platformDisplayLink.onFrame = { [weak self] frame in
            self?.send(frame: frame)
        }
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == Frame {
        dispatchPrecondition(condition: .onQueue(.main))

        let typeErased = AnySubscriber(subscriber)
        let identifier = typeErased.combineIdentifier
        let subscription = Subscription(onCancel: { [weak self] in
            self?.cancelSubscription(for: identifier)
        })
        subscribers[identifier] = typeErased
        subscriber.receive(subscription: subscription)
    }

    private func cancelSubscription(for identifier: CombineIdentifier) {
        dispatchPrecondition(condition: .onQueue(.main))
        subscribers.removeValue(forKey: identifier)
    }

    private func send(frame: Frame) {
        dispatchPrecondition(condition: .onQueue(.main))
        let subscribers = self.subscribers.values
        subscribers.forEach {
            _ = $0.receive(frame) // Ignore demand
        }
    }
}

extension DisplayLink {

    // Represents a frame that is about to be drawn
    public struct Frame {

        // The system timestamp for the frame to be drawn
        public var timestamp: TimeInterval

        // The duration between each display update
        public var duration: TimeInterval
    }
}

extension DisplayLink {
    public convenience init() {
        self.init(platformDisplayLink: PlatformDisplayLink())
    }
}

extension DisplayLink {
    public static let shared = DisplayLink()
}

extension DisplayLink {

    fileprivate final class Subscription: Combine.Subscription {

        var onCancel: () -> Void

        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }

        func request(_ demand: Subscribers.Demand) {
            // Do nothing – subscribers can't impact how often the system draws frames.
        }

        func cancel() {
            onCancel()
        }
    }
}

import CoreVideo

extension DisplayLink {

    /// DisplayLink is used to hook into screen refreshes.
    fileprivate final class PlatformDisplayLink {

        /// The callback to call for each frame.
        var onFrame: ((Frame) -> Void)? = nil

        /// If the display link is paused or not.
        var isPaused: Bool = true {
            didSet {
                guard isPaused != oldValue else { return }
                if isPaused == true {
                    CVDisplayLinkStop(self.displayLink)
                } else {
                    CVDisplayLinkStart(self.displayLink)
                }
            }
        }

        /// The CVDisplayLink that powers this DisplayLink instance.
        var displayLink: CVDisplayLink = {
            var dl: CVDisplayLink? = nil
            CVDisplayLinkCreateWithActiveCGDisplays(&dl)
            return dl!
        }()

        init() {
            CVDisplayLinkSetOutputHandler(self.displayLink, { [weak self] (displayLink, inNow, inOutputTime, flageIn, flagsOut) -> CVReturn in
                let frame = Frame(
                    timestamp: inNow.pointee.timeInterval,
                    duration: inOutputTime.pointee.timeInterval - inNow.pointee.timeInterval)
                
                DispatchQueue.main.async {
                    self?.handle(frame: frame)
                }
                
                return kCVReturnSuccess
            })
        }
        
        deinit {
            isPaused = true
        }
        
        /// Called for each CVDisplayLink frame callback.
        func handle(frame: Frame) {
            guard isPaused == false else { return }
            onFrame?(frame)
        }
    }
}

extension CVTimeStamp {
    fileprivate var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(self.videoTimeScale)
    }
}
