//
//  UniDirectionalDataFlow.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/9/21.
//

import Foundation

protocol UniDirectionalDataFlowType {
    associatedtype InputType

    func apply(_ input: InputType)
}
