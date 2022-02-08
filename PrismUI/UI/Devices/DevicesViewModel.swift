//
//  DevicesViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Combine
import PrismKit


final class DevicesViewModel: BaseViewModel, UniDirectionalDataFlowType {
    typealias InputType = Input

    // MARK: Input
    enum Input {
        case onAppear
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        }
    }

    private let onAppearSubject = PassthroughSubject<Void, Never>()

    // MARK: Output
    @Published private(set) var devices: [SSDevice] = []

    private let managerService: PrismDriver

    init(managerService: PrismDriver = PrismDriver.shared) {
        self.managerService = managerService
        super.init()
        bindInputs()
        bindOutputs()
    }

    private func bindInputs() {
        onAppearSubject.sink { [weak self] _ in
            self?.managerService.start()
        }
        .store(in: &cancellables)
    }

    private func bindOutputs() {
        managerService.addDeviceSubject
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .filter { [devices] in !devices.contains($0) }
            .sink { [unowned self] in self.devices.append($0) }
            .store(in: &cancellables)
    }
}
