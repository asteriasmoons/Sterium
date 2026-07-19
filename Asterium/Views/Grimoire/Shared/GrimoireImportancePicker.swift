
//
//  GrimoireImportancePicker.swift
//  Asterium
//

import SwiftUI

struct GrimoireImportancePicker: View {
    @Binding var importance: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("IMPORTANCE")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        importance = level
                    } label: {
                        ZStack {
                            Circle()
                                .fill(level == importance ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                                .frame(width: 40, height: 40)

                            Circle()
                                .strokeBorder(
                                    level == importance ? AnyShapeStyle(Color.clear) : AnyShapeStyle(LColors.glassBorder),
                                    lineWidth: 1
                                )
                                .frame(width: 40, height: 40)

                            Text("\(level)")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(level == importance ? LColors.bg : LColors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
