import SwiftUI

struct GlassButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let status: AppStatus
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                icon
                
                Text(title)
                    .font(AppFont.button)
                    .id(title)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            .foregroundColor(isEnabled ? AppColor.primaryText : AppColor.mutedText)
            .frame(width: AppSize.primaryButtonWidth, height: AppSize.primaryButtonHeight)
            .contentShape(RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous))
        }
        .buttonStyle(
            AnimatedGlassButtonStyle(
                isHovered: isHovered,
                isEnabled: isEnabled,
                status: status
            )
        )
        .disabled(!isEnabled)
        .onHover { hovering in
            withAnimation(AppMotion.softSpring) {
                isHovered = hovering
            }
        }
        .animation(AppMotion.statusChange, value: status)
    }
    
    @ViewBuilder
    private var icon: some View {
        switch status {
        case .resetting:
            TimelineView(.animation) { timeline in
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColor.electricCyan)
                    .rotationEffect(.degrees(timeline.date.timeIntervalSinceReferenceDate * 260))
                    .frame(width: 26, height: 26)
            }
            .frame(width: 26, height: 26)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColor.softAqua)
                .shadow(color: AppColor.softAqua.opacity(0.55), radius: 9)
                .transition(.opacity.combined(with: .scale(scale: 0.78)))
                .frame(width: 26, height: 26)
        default:
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isEnabled ? AppColor.electricCyan : AppColor.mutedText)
                .frame(width: 26, height: 26)
        }
    }
}

private struct AnimatedGlassButtonStyle: ButtonStyle {
    let isHovered: Bool
    let isEnabled: Bool
    let status: AppStatus
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(buttonFill)
            .overlay(buttonBorder)
            .overlay(buttonHighlight.opacity(isHovered && isEnabled ? 1 : 0.45))
            .overlay(loadingSweep)
            .clipShape(RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous))
            .shadow(color: glowColor.opacity(glowOpacity), radius: isHovered && isEnabled ? 24 : 15, x: 0, y: 0)
            .shadow(color: AppColor.neonMagenta.opacity(status == .success ? 0.28 : 0.12), radius: 22, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.982 : (isHovered && isEnabled ? 1.02 : 1))
            .opacity(isEnabled ? 1 : 0.64)
            .animation(AppMotion.softSpring, value: configuration.isPressed)
            .animation(AppMotion.softSpring, value: isHovered)
            .animation(AppMotion.statusChange, value: status)
    }
    
    private var buttonFill: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous)
                .fill(AppColor.panelBlueBlack.opacity(0.74))
            
            RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.laserBlue.opacity(fillOpacity),
                            AppColor.violetPurple.opacity(fillOpacity * 0.72),
                            AppColor.neonMagenta.opacity(fillOpacity * 0.82)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
    
    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        AppColor.electricCyan.opacity(isEnabled ? 0.9 : 0.2),
                        AppColor.violetPurple.opacity(isEnabled ? 0.78 : 0.18),
                        AppColor.neonMagenta.opacity(isEnabled ? 0.72 : 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isHovered && isEnabled ? 1.8 : 1.25
            )
    }
    
    private var buttonHighlight: some View {
        RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        AppColor.primaryText.opacity(0.42),
                        .clear,
                        AppColor.electricCyan.opacity(0.28)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .blendMode(.screen)
    }
    
    @ViewBuilder
    private var loadingSweep: some View {
        if status == .resetting {
            TimelineView(.animation) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 1.05) / 1.05
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                AppColor.softAqua.opacity(0.2),
                                AppColor.electricCyan.opacity(0.42),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 86, height: AppSize.primaryButtonHeight + 18)
                    .rotationEffect(.degrees(12))
                    .offset(x: -AppSize.primaryButtonWidth / 2 - 60 + CGFloat(phase) * (AppSize.primaryButtonWidth + 120))
                    .blur(radius: 2.4)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppSize.buttonRadius, style: .continuous))
            .allowsHitTesting(false)
        }
    }
    
    private var fillOpacity: Double {
        switch status {
        case .resetting:
            return 0.34
        case .success:
            return 0.42
        default:
            return isHovered && isEnabled ? 0.34 : 0.24
        }
    }
    
    private var glowColor: Color {
        switch status {
        case .success:
            return AppColor.softAqua
        case .expired:
            return AppColor.dangerPinkRed
        default:
            return AppColor.electricCyan
        }
    }
    
    private var glowOpacity: Double {
        if !isEnabled { return 0.08 }
        switch status {
        case .resetting:
            return 0.32
        case .success:
            return 0.42
        default:
            return isHovered ? 0.34 : 0.22
        }
    }
}
