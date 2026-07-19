
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
                    .fill(LColors.glassSurface2)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        LColors.gradientBlue.opacity(0.18),
                                        LColors.gradientPurple.opacity(0.22),
                                        Color.white.opacity(0.03)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        LColors.gradientBlue.opacity(0.92),
                                        LColors.gradientPurple.opacity(0.92),
                                        Color.white.opacity(0.38)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.05
                            )
                    }
            }
            .shadow(color: LColors.gradientBlue.opacity(0.18), radius: 16, y: 8)
            .shadow(color: LColors.gradientPurple.opacity(0.14), radius: 18, y: 10)
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
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }
}

struct AsteriumPickerField: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack {
                        Text(selection.isEmpty ? "Choose" : selection)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(selection.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                        Spacer()
                        Text("⌄")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(LGradients.header)
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)
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
