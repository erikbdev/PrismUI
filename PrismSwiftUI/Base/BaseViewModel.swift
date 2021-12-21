//
//  BaseViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/2/21.
//

import Combine

class BaseViewModel: ObservableObject {
    internal lazy var cancellables: Set<AnyCancellable> = .init()
}
