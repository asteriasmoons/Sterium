//
//  IconPickerView.swift
//  Sterium
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selection: String
    @State private var selectedCategory: String

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    init(selection: Binding<String>) {
        _selection = selection
        let initialCategory = IconLibrary.category(containing: selection.wrappedValue)
            ?? IconLibrary.categoryNames.first
            ?? ""
        _selectedCategory = State(initialValue: initialCategory)
    }

    private var icons: [String] {
        IconLibrary.icons(for: selectedCategory)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumPickerField(
                title: "Icon Category",
                options: IconLibrary.categoryNames,
                selection: $selectedCategory
            )

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(icons, id: \.self) { asset in
                    Button {
                        selection = asset
                    } label: {
                        Image(asset)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(selection == asset ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.textSecondary))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(selection == asset ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassBorder), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
