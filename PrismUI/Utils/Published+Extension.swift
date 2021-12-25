//
//  Published+Extension.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/24/21.
//

import Foundation
import Combine

extension Published.Publisher {
    var didSink: AnyPublisher<Output, Failure> {
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
