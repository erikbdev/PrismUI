//
//  PerKeyKeyboardView.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/9/22.
//

import SwiftUI
import PrismKit

public struct PerKeyKeyboardView: View {
    let model: SSModels
    let items: [[SSKey]]
    let selectionCallback: (IndexPath) -> Void
    let selected: Set<IndexPath>

    public var body: some View {
        let padding = 6.0

        VStack(spacing: padding) {
            ForEach(items.indices, id: \.self) { row in
                HStack(alignment: .top, spacing: padding) {
                    ForEach(items[row].indices, id: \.self) { column in
                        let item = items[row][column]
                        let index = IndexPath(item: column, section: row)

                        if let keyLayout = SSPerKeyProperties.getKeyLayout(for: item, model: model, padding: padding) {
//                            KeyView(item: item,
//                                    selected: selected.contains(index),
//                                    action: {
//                                        selectionCallback(index)
//                                    }
//                                )
//                            .equatable()
                            KeyView(
                                viewModel: .make(
                                    extra: .init(
                                        ssKey: item,
                                        tapGestureCallback: {
                                            selectionCallback(index)
                                        }
                                    )
                                ),
                                selected: selected.contains(index)
                            )
                                .equatable()
                                .frame(minWidth: keyLayout.width,
                                       minHeight: keyLayout.height,
                                       maxHeight: keyLayout.height)
                                .offset(y: keyLayout.yOffset)
                            if keyLayout.addExtraView {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(minWidth: keyLayout.width,
                                           minHeight: keyLayout.height,
                                           maxHeight: keyLayout.height)
                            }
                        }
                    }
                }
            }
        }
        .animation(.easeIn(duration: 0.25), value: selected)
    }
}

struct PerKeyKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        PerKeyKeyboardView(model: .perKey, items: [[SSKey(name: "yes", region: 0, keycode: 0)]], selectionCallback: { _ in }, selected: .init())
            .frame(width: 500, height: 300, alignment: .center)
    }
}
