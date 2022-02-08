//
//  PrismDriverService.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/7/22.
//

import Combine
import PrismKit

class PrismDriverService: ObservableObject {
    private let prismDriverService: PrismDriver = .init()
    private var cancellables: Set<AnyCancellable> = .init()

    @Published var devices: [SSDevice] = []

    init() {
        setup()
    }

    private func setup() {
        prismDriverService.addDeviceSubject
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .filter { [devices] in !devices.contains($0) }
            .sink(receiveValue: { [unowned self] in self.devices.append($0) })
            .store(in: &cancellables)

        prismDriverService.removeDeviceSubject
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] device in self.devices.removeAll(where: { $0.id == device.id }) })
            .store(in: &cancellables)
    }

    public func startScan() {
        prismDriverService.start()
    }

    public func stopScan() {
        prismDriverService.stop()
    }
}
