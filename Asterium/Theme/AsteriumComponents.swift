
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AsteriumBackground: View {
        var body: some View {
            ZStack {
                // Base background
                LColors.bg
                    .ignoresSafeArea()
            }
        }
    }

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var padding: CGFloat = LSpacing.cardPadding
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(seeryHex: "#09090d").opacity(0.90))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.045))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(seeryHex: "#bca64d").opacity(0.26),
                                        Color(seeryHex: "#ad640a").opacity(0.14),
                                        Color(seeryHex: "#2a1607").opacity(0.045),
                                        Color(seeryHex: "#07070a").opacity(0.0)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(seeryHex: "#bca64d").opacity(0.16),
                                        Color(seeryHex: "#ad640a").opacity(0.08),
                                        Color.white.opacity(0.055),
                                        Color.white.opacity(0.035)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    }
            }
            .shadow(color: Color.black.opacity(0.42), radius: 18, y: 10)
            .shadow(color: Color(seeryHex: "#ad640a").opacity(0.045), radius: 10, y: 4)
    }
}

struct AsteriumPageHeader: View {
    let eyebrow: String
    let title: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
            }
        }
        .padding(.top, 16)
    }
}

struct AsteriumSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
    }
}

struct AsteriumTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)
            GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .padding(14)
            }
        }
    }
}

struct AsteriumNumberedListField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @State private var draft = ""
    @State private var isExpanded = true

    private var items: [String] {
        text.split(separator: "\n").map { String($0) }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            HStack(spacing: 10) {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    TextField(placeholder, text: $draft)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .onSubmit { addItem() }
                }

                Button(action: addItem) {
                    Image("addwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 44, height: 44)
                        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(LColors.glassBorder, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }

            if !items.isEmpty {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Ingredients & Tools")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)

                                Spacer()

                                Image(isExpanded ? "chevup" : "chevdown")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(LGradients.header)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if isExpanded {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                                    HStack(spacing: 10) {
                                        Text("\(index + 1).")
                                            .font(.system(size: 15, weight: .black, design: .rounded))
                                            .foregroundStyle(LGradients.header)

                                        Text(item)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(LColors.textPrimary)

                                        Spacer()

                                        Button {
                                            removeItem(at: index)
                                        } label: {
                                            Image("xmarkwavy")
                                                .renderingMode(.template)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(LGradients.header)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
    }

    private func addItem() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        text = items.isEmpty ? value : items.joined(separator: "\n") + "\n" + value
        draft = ""
    }

    private func removeItem(at index: Int) {
        var updatedItems = items
        guard updatedItems.indices.contains(index) else { return }
        updatedItems.remove(at: index)
        text = updatedItems.joined(separator: "\n")
    }
}

struct AsteriumDynamicStepsField: View {
    let title: String
    @Binding var steps: [String]
    var maxSteps: Int = 9

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            VStack(spacing: 10) {
                ForEach(steps.indices, id: \.self) { index in
                    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                        TextField("Step \(index + 1)...", text: $steps[index], axis: .vertical)
                            .lineLimit(1...4)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .padding(14)
                    }
                }
            }

            if steps.count < maxSteps {
                Button {
                    steps.append("")
                } label: {
                    Image("addwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 44, height: 44)
                        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(LColors.glassBorder, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            if steps.isEmpty { steps = [""] }
            if steps.count > maxSteps { steps = Array(steps.prefix(maxSteps)) }
        }
    }
}

struct AsteriumTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)
            GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .padding(10)
                        .frame(minHeight: minHeight)
                }
            }
        }
    }
}

struct AsteriumDateField: View {
    let title: String
    @Binding var date: Date
    var includesTime = false

    @State private var showPicker = false

    private var formattedDate: String {
        if includesTime {
            return date.formatted(.dateTime.month(.wide).day().year().hour().minute())
        } else {
            return date.formatted(.dateTime.month(.wide).day().year())
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                    showPicker.toggle()
                }
            } label: {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack {
                        Text(formattedDate)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)

                        Spacer()

                        Image("grimoire")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LGradients.header)
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)

            if showPicker {
                GlassCard(cornerRadius: LSpacing.cardRadius, padding: 12) {
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: includesTime ? [.date, .hourAndMinute] : [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .tint(LColors.accent)
                    .colorScheme(.dark)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }
}

struct AsteriumPickerField: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack {
                        Text(selection.isEmpty ? "Choose" : selection)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(selection.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                        Spacer()
                        Image(isExpanded ? "chevup" : "chevdown")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LGradients.header)
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 8) {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    selection = option
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                        isExpanded = false
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundStyle(selection == option ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.textPrimary))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(selection == option ? LColors.glassSurface : Color.clear, in: RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 320)
                    .scrollIndicators(.visible)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
    }
}

struct AsteriumMultiSelectPickerField: View {
    let title: String
    let options: [String]
    @Binding var selections: Set<String>
    @State private var isExpanded = false

    private var displayText: String {
        let ordered = options.filter { selections.contains($0) }
        return ordered.isEmpty ? "Choose" : ordered.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack {
                        Text(displayText)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(selections.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                            .lineLimit(2)
                        Spacer()
                        Image(isExpanded ? "chevup" : "chevdown")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LGradients.header)
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 8) {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    if selections.contains(option) {
                                        selections.remove(option)
                                    } else {
                                        selections.insert(option)
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundStyle(selections.contains(option) ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.textPrimary))
                                        Spacer()
                                        if selections.contains(option) {
                                            Image("checkwavy")
                                                .renderingMode(.template)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(LGradients.header)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(selections.contains(option) ? LColors.glassSurface : Color.clear, in: RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 320)
                    .scrollIndicators(.visible)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
    }
}

@ViewBuilder
private func fieldLabel(_ title: String) -> some View {
    Text(title)
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

struct AsteriumPrimaryButton: View {
    let title: String
    var asset: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let asset {
                    Image(asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                }
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(LColors.bg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(LGradients.header, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
        }
        .buttonStyle(.plain)
    }
}



struct AsteriumCompletionBanner: View {
    let message: String
    var isShowing: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image("checkwavy")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(.white)

            Text(message)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(LGradients.header)
                .shadow(color: LColors.gradientPurple.opacity(0.4), radius: 16, y: 6)
        )
        .opacity(isShowing ? 1 : 0)
        .offset(y: isShowing ? 0 : -20)
        .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isShowing)
    }
}

extension View {
    func completionBanner(isShowing: Bool, message: String = "Done!") -> some View {
        overlay(alignment: .top) {
            AsteriumCompletionBanner(message: message, isShowing: isShowing)
                .padding(.top, 16)
                .zIndex(999)
        }
    }

    @ViewBuilder
    func asteriumAdaptivePresentation<Sheet: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Sheet
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            fullScreenCover(isPresented: isPresented, content: content)
        } else {
            sheet(isPresented: isPresented, content: content)
        }
    }
}
