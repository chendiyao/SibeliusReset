import SwiftUI

struct InfoPanel: View {
    let lastResetDate: String
    let nextExpireDate: String
    
    var body: some View {
        VStack(spacing: 10) {
            DateInfoRow(
                icon: "clock.arrow.circlepath",
                label: "上次",
                value: normalizedLastResetDate
            )
            
            DateInfoRow(
                icon: "calendar.badge.clock",
                label: "到期",
                value: normalizedNextExpireDate
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .frame(width: AppSize.infoPanelWidth, height: AppSize.infoPanelHeight)
        .background(
            RoundedRectangle(cornerRadius: AppSize.infoPanelRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.primaryText.opacity(0.055),
                            AppColor.panelBlueBlack.opacity(0.54),
                            AppColor.deepSpaceBlack.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppSize.infoPanelRadius, style: .continuous)
                        .stroke(AppColor.primaryText.opacity(0.11), lineWidth: 1)
                )
                .shadow(color: AppColor.electricCyan.opacity(0.06), radius: 18, x: 0, y: 10)
        )
        .animation(AppMotion.softSpring, value: normalizedLastResetDate)
        .animation(AppMotion.softSpring, value: normalizedNextExpireDate)
    }
    
    private var normalizedLastResetDate: String {
        lastResetDate == "--" ? "未重置" : lastResetDate
    }
    
    private var normalizedNextExpireDate: String {
        nextExpireDate == "--" ? "重置后生成" : nextExpireDate
    }
}

private struct DateInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.secondaryText)
                .frame(width: 18)
            
            Text(label)
                .foregroundColor(AppColor.secondaryText)
                .frame(width: 32, alignment: .leading)
            
            Spacer(minLength: 10)
            
            Text(value)
                .foregroundColor(AppColor.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .id(value)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
        .font(AppFont.info)
    }
}
