import SwiftUI

struct SubmittedReportImageView: View {
    @Environment(\.dismiss) private var dismiss
    let attachment: SubmittedReportAttachment

    @State private var scale: CGFloat = 1
    @State private var settledScale: CGFloat = 1

    var body: some View {
        ZStack {
            AsteriumBackground().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    AsteriumPageHeader(eyebrow: "ATTACHMENT", title: attachment.displayName)
                    Spacer()
                    Button { dismiss() } label: {
                        Image("xmarkwavy")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                            .foregroundStyle(LGradients.header)
                            .frame(width: 44, height: 44)
                            .background(LColors.glassSurface, in: Circle())
                            .overlay { Circle().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)
                }
                .padding(.horizontal, LSpacing.pageHorizontal)

                GeometryReader { proxy in
                    ScrollView([.horizontal, .vertical]) {
                        if let image = UIImage(data: attachment.imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .scaleEffect(scale)
                                .gesture(
                                    MagnifyGesture()
                                        .onChanged { value in
                                            scale = min(max(settledScale * value.magnification, 1), 5)
                                        }
                                        .onEnded { _ in
                                            settledScale = scale
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                        scale = scale > 1 ? 1 : 2
                                        settledScale = scale
                                    }
                                }
                        } else {
                            VStack(spacing: 12) {
                                Image("imagesign")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(LColors.textSecondary)
                                Text("Image unavailable")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                            }
                            .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }
}
