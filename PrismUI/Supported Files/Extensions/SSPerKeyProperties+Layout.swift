//
//  SSPerKeyProperties+Layout.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/24/21.
//

import PrismClient

// Layout Map
extension PerKeyProperties {
    // Not exactly equaling to 20 because of some emtpy spaces in between the keys

    static let perKeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],   // 20
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75, 1, 1, 1, 1],   // 20
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.50, 1, 1, 1],      // 19
        [2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1],            // 20
        [2.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.5, 1, 1, 1, 1],           // 19
        [2, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]                      // 20
    ]

    static let perKeyKeySize: CGFloat = 50.0

    static let perKeyGS65KeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],          // 15
        [0.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1],    // 15
        [0.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.25, 1],    // 15
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.75, 1],       // 15
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1, 1],       // 15
        [1.25, 1, 1, 4.75, 1, 1, 1, 1, 1, 1, 1]                 // 15
    ]

    static let perKeyGS65KeySize: CGFloat = 60.0

    static func getKeyboardMap(for model: Models) -> [[CGFloat]] {
        switch model {
        case .perKey:
            return perKeyMap
        case .perKeyGS65:
            return perKeyGS65KeyMap
        default:
            return []
        }
    }

    static func getKeyboardCodes(for model: Models) -> [[(UInt8, UInt8)]] {
        switch model {
        case .perKey:
            return perKeyRegionKeyCodes
        case .perKeyGS65:
            return perKeyGS65RegionKeyCodes
        default:
            return []
        }
    }
}

// Generating Layout for a key

extension PerKeyProperties {
    public struct KeyLayout: Hashable {
        let width: CGFloat
        let height: CGFloat
        let yOffset: CGFloat
        let requiresExtraView: Bool
    }

    public static func getKeyLayout(for key: Key, model: Models, padding: CGFloat) -> KeyLayout? {
        let keyCodes: [[(UInt8, UInt8)]] = PerKeyProperties.getKeyboardCodes(for: model)
        let keyMaps: [[CGFloat]] = PerKeyProperties.getKeyboardMap(for: model)
        let keySizes: CGFloat = model == .perKey ? PerKeyProperties.perKeyKeySize : PerKeyProperties.perKeyGS65KeySize

        let rowIndex = keyCodes.firstIndex { column in
            column.contains { (region, keycode) in
                key.region == region && key.keycode == keycode
            }
        }

        if let rowIndex = rowIndex {
            let columnIndex = keyCodes[rowIndex].firstIndex { region, keycode in
                key.region == region && key.keycode == keycode
            }

            if let columnIndex = columnIndex {
                let keyMap = keyMaps[rowIndex][columnIndex]

                let keyWidth = keySizes * keyMap
                let keyHeight = (key.keycode == 0x57 || key.keycode == 0x56) ? keySizes * 2 + padding : keySizes
                let addExtraView = key.keycode == 0x5A || key.keycode == 0x60

                let keyYOffset: CGFloat
                if model == .perKey {
                    if key.keycode == 0x57 {
                        keyYOffset = -keySizes - padding
                    } else if rowIndex <= 3 && key.keycode != 0x56 {
                        keyYOffset = keySizes + padding
                    } else {
                        keyYOffset = 0
                    }
                } else {
                   keyYOffset = 0
                }

                return .init(width: keyWidth, height: keyHeight, yOffset: keyYOffset, requiresExtraView: addExtraView)
            }
        }

        return nil
    }
}

//    static func getKeys(for model: Models) -> [[KeyData]] {
//        let keyMaps: [[CGFloat]] = getKeyboardMap(for: model)
//        let keyCodes: [[(UInt8, UInt8)]] = getKeyboardCodes(for: model)
//        let keySizes: CGFloat = model == .perKey ? perKeyKeySize : perKeyGS65KeySize
//        let keyNames: [[String]] = model == .perKey ? perKeyNames : perKeyGS65KeyNames
//
//        var keyDataArray: [[KeyData]] = []
//
//        for i in keyCodes.enumerated() {
//            let row = i.offset
//            keyDataArray.append([])
//            for j in i.element.enumerated() {
//                let column = j.offset
//
//                let keyMap = keyMaps[row][column]
//                let keyRegion = j.element.0
//                let keyCode = j.element.1
//                let keyWidth = keySizes * keyMap
//                let keyHeight = model == .perKeyGS65 ? PerKeyProperties.perKeyGS65KeySize : (keyCode == 0x57 || keyCode == 0x56) ? 108 : SSPerKeyProperties.perKeyKeySize
//                let keyName = keyNames[row][column]
//                let keyData = KeyData(ssKey: .init(name: keyName, region: keyRegion, keycode: keyCode),
//                                      keySize: .init(width: keyWidth, height: keyHeight)
//                )
//
//                keyDataArray[row].append(keyData)
//            }
//        }
//
//        return keyDataArray
//    }
//
//    struct KeyData {
//        let ssKey: Key
//        let keySize: CGSize
//    }

