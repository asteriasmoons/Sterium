//
//  HomeCustomizeView.swift
//  Sterium
//
//  Customize which homepage widgets appear and in what order. Drag to
//  reorder; tap the eye to hide/show. Hiding preserves a widget's placement
//  so it returns to the same spot when shown again.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct HomeCustomizeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var layouts: [HomeWidgetLayout]

    @State private var widgets: [HomeWidget] = []
    @State private var hidden: Set<HomeWidget> = []
    @State private var dragging: HomeWidget?
    @State private var didLoad = false

    private var shownCount: Int { widgets.filter { hidden.contains($0) == false }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header
                    intro

                    VStack(spacing: 12) {
                        ForEach(widgets) { widget in
                            row(widget)
                        }
                    }

                    resetButton
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.top, 4)
                .padding(.bottom, 120)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: widgets)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: hidden)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear(perform: loadIfNeeded)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CUSTOMIZE")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)
                Text("Home Widgets")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button { dismiss() } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 42, height: 42)
                    .background(LColors.glassSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    private var intro: some View {
        Text("Drag to reorder. Tap the eye to hide a widget — hidden widgets keep their place and return when you show them again. \(shownCount) shown.")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Row

    private func row(_ widget: HomeWidget) -> some View {
        let isHidden = hidden.contains(widget)
        let isDragging = dragging == widget

        return GlassCard(cornerRadius: 18, padding: 14) {
            HStack(spacing: 12) {
                gripHandle

                ZStack {
                    Circle()
                        .fill(LColors.glassSurface)
                        .frame(width: 44, height: 44)
                    Image(widget.icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(LGradients.header)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(widget.title)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .lineLimit(1)
                    Text(isHidden ? "Hidden" : widget.subtitle)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(isHidden ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.textSecondary))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Button { toggle(widget) } label: {
                    Image(isHidden ? "eyeslash" : "eye")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(isHidden ? AnyShapeStyle(LColors.textSecondary) : AnyShapeStyle(LGradients.header))
                        .frame(width: 40, height: 40)
                        .background(LColors.glassSurface, in: Circle())
                        .overlay { Circle().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(isHidden ? 0.55 : 1)
        .overlay {
            if isDragging {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(LGradients.header, lineWidth: 1.5)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onDrag {
            dragging = widget
            return NSItemProvider(object: widget.id as NSString)
        }
        .onDrop(
            of: [UTType.text],
            delegate: WidgetDropDelegate(item: widget, items: $widgets, dragging: $dragging, onReorder: persist)
        )
    }

    private var gripHandle: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(LColors.textSecondary)
                    .frame(width: 16, height: 2)
            }
        }
        .frame(width: 26, height: 26)
    }

    // MARK: - Reset

    private var resetButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                widgets = HomeWidget.defaultOrder
                hidden = []
            }
            persist()
        } label: {
            HStack(spacing: 10) {
                Image("repeatarrows")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("Reset to Default")
                    .font(.system(size: 15, weight: .black, design: .rounded))
            }
            .foregroundStyle(LGradients.header)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.buttonRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data

    private func loadIfNeeded() {
        guard didLoad == false else { return }
        didLoad = true
        let layout = currentLayout()
        widgets = layout.resolvedOrder
        hidden = layout.hidden
    }

    private func toggle(_ widget: HomeWidget) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            if hidden.contains(widget) {
                hidden.remove(widget)
            } else {
                hidden.insert(widget)
            }
        }
        persist()
    }

    private func persist() {
        let layout = currentLayout()
        layout.order = widgets
        layout.hidden = hidden
        layout.updatedAt = Date()
        try? modelContext.save()
    }

    private func currentLayout() -> HomeWidgetLayout {
        if let existing = layouts.sorted(by: { $0.updatedAt > $1.updatedAt }).first {
            return existing
        }
        let created = HomeWidgetLayout()
        modelContext.insert(created)
        return created
    }
}

// MARK: - Drop delegate (live reorder)

private struct WidgetDropDelegate: DropDelegate {
    let item: HomeWidget
    @Binding var items: [HomeWidget]
    @Binding var dragging: HomeWidget?
    let onReorder: () -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging,
              dragging != item,
              let from = items.firstIndex(of: dragging),
              let to = items.firstIndex(of: item)
        else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        onReorder()
        return true
    }
}
