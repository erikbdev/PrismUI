//
//  PerKeyControllerClient+Live.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/27/22.
//

import Foundation

extension PerKeyControllerClient {
    public static func live(for device: PrismDevice.State) -> Self {
        Self { updateKeys in
                .fireAndForget {
                    let keyCodeCount = device.model == .perKey ? PerKeyProperties.perKeyRegionKeyCodes : PerKeyProperties.perKeyShortRegionKeyCodes

                    guard updateKeys.count == keyCodeCount.flatMap({ $0 }).count else {
                        Log.error("Data not matching keyCodes required for: \(device.model)")
                        return
                    }

                    // MARK: Update effects first

                    // First get colorShift and breathing effects

                    let customEffects = updateKeys.compactMap({ $0.effect }).filter({ $0.mode == .colorShift || $0.mode == .breathing }).uniqued()

                    // Now we generate an id for each custom effect.

                    var customEffectsWithId = [UInt8: Key.Effect]()

                    if customEffects.count > 0 {
                        for (index, customEffect) in customEffects.enumerated() {
                            let id = UInt8(index + 1)
                            customEffectsWithId[id] = customEffect

                            if let serializedEffect = serializeEffect(id: id, effect: customEffect) {
                                // Send effect as a feature report to device
                                _ = device.device.sendFeatureReport(data: serializedEffect)
                            } else {
                                Log.error("There was an error communicating with \(device.model))")
                                return
                            }
                        }
                    }

                    // Now update the keyboard with updated

                    let updateModifiers = updateKeys.filter { $0.region == PerKeyProperties.regions[0] }.count > 0
                    let updateAlphanums = updateKeys.filter { $0.region == PerKeyProperties.regions[1] }.count > 0
                    let updateEnter = updateKeys.filter { $0.region == PerKeyProperties.regions[2] }.count > 0
                    let updateSpecial = updateKeys.filter { $0.region == PerKeyProperties.regions[3] }.count > 0

                    var lastByte: UInt8 = 0

                    if updateModifiers {
                        lastByte = 0x2d

                        let serializedKeys = serializeKeys(
                            keys: updateKeys,
                            region: PerKeyProperties.regions[0],
                            keycodes: PerKeyProperties.modifiers,
                            effectsWithId: customEffectsWithId
                        )

                        if let data = serializedKeys {
                            _ = device.device.sendFeatureReport(data: data)
                        } else {
                            Log.error("There was an error serializing modifier keys for \(device.model).")
                            return
                        }
                    }

                    if updateAlphanums {
                        lastByte = 0x08

                        let serializedKeys = serializeKeys(
                            keys: updateKeys,
                            region: PerKeyProperties.regions[1],
                            keycodes: PerKeyProperties.alphanums,
                            effectsWithId: customEffectsWithId
                        )

                        if let data = serializedKeys {
                            _ = device.device.sendFeatureReport(data: data)
                        } else {
                            Log.error("There was an error serializing alphanum keys for \(device.model).")
                            return
                        }
                    }

                    if updateEnter {
                        lastByte = 0x87

                        let serializedKeys = serializeKeys(
                            keys: updateKeys,
                            region: PerKeyProperties.regions[2],
                            keycodes: PerKeyProperties.enter,
                            effectsWithId: customEffectsWithId
                        )

                        if let data = serializedKeys {
                            _ = device.device.sendFeatureReport(data: data)
                        } else {
                            Log.error("There was an error serializing enter keys for \(device.model).")
                            return
                        }
                    }

                    if updateSpecial {
                        lastByte = 0x44

                        let serializedKeys = serializeKeys(
                            keys: updateKeys,
                            region: PerKeyProperties.regions[3],
                            keycodes: device.model == .perKey ? PerKeyProperties.special : PerKeyProperties.specialShort,
                            effectsWithId: customEffectsWithId
                        )

                        if let data = serializedKeys {
                            _ = device.device.sendFeatureReport(data: data)
                        } else {
                            Log.error("There was an error serializing special keys for \(device.model).")
                            return
                        }
                    }

                    // Update keyboard with new feature reports

                    let serializedOutputData = serializeWriteOutput(lastByte: lastByte)
                    _ = device.device.write(data: serializedOutputData)
                }
        }
    }
}

// MARK: Serialization

extension PerKeyControllerClient {
    private static func serializeEffect(id effectId: UInt8, effect: Key.Effect) -> Data? {
        guard effect.transitions.count > 0 else {
            // Must have at least one transition or will return error
            Log.error("An effect has no transitions. Will not update keyboard with no transitions due to it can cause bricking keyboard.")
            return nil
        }
        
        guard effect.transitions.map({ $0.position }).isUnique else {
            // Must have unique positions in each transition or keyboard may brick.
            Log.error("A transition must have unique positions. Will not update keyboard with no transitions due to it can cause bricking keyboard.")
            return nil
        }
        
        var data = Data(capacity: PerKeyProperties.packageSize)
        data.append([0x0b, 0x00], count: 2) // Start Packet
        
        let totalDuration = effect.duration
        
        // Transitions - each transition will take 8 bytes, sort transitions based on their position
        let transitions = effect.transitions.sorted(by: { $0.position < $1.position })
        for (index, transition) in transitions.enumerated() {
            let idx = UInt8(index)
            
            let nextTransition = (index + 1) < transitions.count ? transitions[index + 1] : transitions[0]
            
            var deltaPosition =  nextTransition.position - transition.position
            if deltaPosition < 0 { deltaPosition += 1.0 }
            
            let duration = UInt16((deltaPosition * CGFloat(totalDuration)) / 10)
            
            // Calculate color difference
            
            let colorDelta = RGB.delta(source: transition.color, target: nextTransition.color, duration: duration)
            
            data.append(
                [
                    index == 0 ? effectId : idx,
                    0x0,
                    colorDelta.redUInt,
                    colorDelta.greenUInt,
                    colorDelta.blueUInt,
                    0x0,
                    UInt8(duration & 0x00ff),
                    UInt8(duration >> 8)
                ],
                count: 8
            )
        }

        // Fill spaces
        var fillZeros = [UInt8](repeating: 0x00, count: 0x84 - data.count)
        data.append(fillZeros, count: fillZeros.count)
        
        // Set starting color, each value will have 2 bytes
        data.append(
            [
                (effect.main.redUInt & 0x0f) << 4,
                (effect.main.redUInt & 0xf0) >> 4,
                (effect.main.greenUInt & 0x0f) << 4,
                (effect.main.greenUInt & 0xf0) >> 4,
                (effect.main.blueUInt & 0x0f) << 4,
                (effect.main.blueUInt & 0xf0) >> 4,
                0xff,
                0x00
            ],
            count: 8
        )
        
        // Wave mode
        
        if effect.waveActive {
            let origin = effect.origin
            
            let originX = UInt16(origin.x * 0x105c)
            let originY = UInt16(origin.y * 0x40d)
            
            data.append(
                [
                    UInt8(originX & 0x00ff),
                    UInt8(originX >> 8),
                    UInt8(originY & 0x00ff),
                    UInt8(originY >> 8),
                    effect.direction != .y ? 0x01 : 0x00,
                    0x00,
                    effect.direction != .x ? 0x01 : 0x00,
                    0x00,
                    UInt8(effect.pulse & 0x00ff),
                    UInt8(effect.pulse >> 8)
                ],
                count: 10
            )
        } else {
            fillZeros = [UInt8](repeating: 0x00, count: 10)
            data.append(fillZeros, count: fillZeros.count)
        }
        
        data.append(
            [
                UInt8(effect.transitions.count),
                0x00,
                UInt8(effect.duration & 0x00ff),
                UInt8(effect.duration >> 8),
                effect.control.rawValue
            ],
            count: 5
        )
        
        // Fill remaining with zeros
        fillZeros = [UInt8](repeating: 0x00, count: PerKeyProperties.packageSize - data.count)
        data.append(fillZeros, count: fillZeros.count)
        return data
    }
    
    private static func serializeKeys(keys: [Key], region: UInt8, keycodes: [UInt8], effectsWithId: [UInt8: Key.Effect]) -> Data? {
        var data = Data(capacity: PerKeyProperties.packageSize)

        // This array contains only the usable keys for this region
        let keyboardKeys = keys.filter { $0.region == region }

        for keyCode in [region] + keycodes {
            if let key = keyboardKeys.filter({ $0.region == region && $0.keycode == keyCode }).first {
                // If the effect is on .colorShift or .breathing, this value has to be 0x12c
                var duration = key.effect.duration
                var mode: UInt8 = 0
                switch key.effect.mode {
                case .steady:
                    mode = 0x01
                case .reactive:
                    mode = 0x08
                case .disabled:
                    mode = 0x03
                default:
                    mode = 0
                    duration = 0x12c
                }

                if key.keycode == key.region {
                    data.append([0x0e, 0x0, key.keycode, 0x0], count: 4)
                } else {
                    data.append([0x0, key.keycode], count: 2)
                }

                let effectId: UInt8 = effectsWithId.first(where: { $0.value == key.effect })?.key ?? 0

                data.append(
                    [
                        key.effect.main.redUInt,
                        key.effect.main.greenUInt,
                        key.effect.main.blueUInt,
                        key.effect.active.redUInt,
                        key.effect.active.greenUInt,
                        key.effect.active.blueUInt,
                        UInt8(duration & 0x00ff),
                        UInt8(duration >> 8),
                        effectId,
                        mode
                    ],
                    count: 10
                )
            } else {
                data.append(
                    [
                        0x0,
                        keyCode,
                        0, 0, 0, 0, 0, 0,
                        0x2c,
                        0x01,
                        0,
                        0
                    ],
                    count: 12
                )
            }
        }
        
        // Fill rest of data with the remaining capacity
        let sizeRemaining = PerKeyProperties.packageSize - data.count
        data.append([UInt8](repeating: 0, count: sizeRemaining), count: sizeRemaining)
        return data
    }

    private static func serializeWriteOutput(lastByte: UInt8) -> Data {
        var data = Data(capacity: 0x40)
        data.append([0x0d, 0x0, 0x02], count: 3)
        data.append([UInt8](repeating: 0, count: 60), count: 60)
        data.append([lastByte], count: 1)
        return data
    }
}

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

private extension Sequence where Element: Hashable {
    var isUnique: Bool {
        var seen = Set<Element>()
        return allSatisfy { seen.insert($0).inserted }
    }
}
