import SwiftUI

struct HUDCircleView: View {
    @ObservedObject var viewModel: ResetViewModel
    
    var body: some View {
        ZStack {
            orbitGuides
            particles
            progressGlow
            progressRing
            innerCore
            if viewModel.status == .resetting {
                ResetProcessingOverlay()
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
            centerContent
        }
        .frame(width: AppSize.countdownOuterSize, height: AppSize.countdownOuterSize)
        .animation(AppMotion.softSpring, value: viewModel.remainingDaysString)
        .animation(AppMotion.statusChange, value: viewModel.status)
    }
    
    private var orbitGuides: some View {
        ZStack {
            Circle()
                .stroke(
                    AppColor.primaryText.opacity(0.075),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 10])
                )
                .frame(width: AppSize.countdownOuterSize, height: AppSize.countdownOuterSize)
            
            Circle()
                .stroke(AppColor.electricCyan.opacity(viewModel.status == .unreset ? 0.06 : 0.12), lineWidth: 1)
                .frame(width: AppSize.countdownRingSize + 20, height: AppSize.countdownRingSize + 20)
            
            Circle()
                .stroke(AppColor.mutedText.opacity(0.13), lineWidth: 2)
                .frame(width: AppSize.countdownRingSize, height: AppSize.countdownRingSize)
        }
    }
    
    private var progressGlow: some View {
        Circle()
            .trim(from: 0, to: ringTrim)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: gradientColors),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 14, lineCap: .round)
            )
            .frame(width: AppSize.countdownRingSize, height: AppSize.countdownRingSize)
            .rotationEffect(.degrees(-90))
            .blur(radius: 6)
            .opacity(glowOpacity)
    }
    
    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: ringTrim)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: gradientColors),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 8.5, lineCap: .round)
            )
            .frame(width: AppSize.countdownRingSize, height: AppSize.countdownRingSize)
            .rotationEffect(.degrees(-90))
            .shadow(color: primaryRingColor.opacity(viewModel.status == .unreset ? 0.08 : 0.3), radius: 8)
            .overlay(trailingNode)
    }
    
    private var innerCore: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        AppColor.panelBlueBlack.opacity(0.9),
                        AppColor.midnightNavy.opacity(0.96),
                        AppColor.deepSpaceBlack.opacity(0.98)
                    ]),
                    center: .center,
                    startRadius: 14,
                    endRadius: AppSize.countdownInnerSize / 2
                )
            )
            .frame(width: AppSize.countdownInnerSize, height: AppSize.countdownInnerSize)
            .overlay(
                Circle()
                    .stroke(AppColor.primaryText.opacity(0.08), lineWidth: 1)
            )
    }
    
    private var centerContent: some View {
        VStack(spacing: 2) {
            if viewModel.status == .resetting {
                Text("处理中")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(AppColor.softAqua)
                    .shadow(color: AppColor.electricCyan.opacity(0.45), radius: 10)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else if viewModel.status == .success {
                Text("完成")
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(AppColor.softAqua)
                    .shadow(color: AppColor.electricCyan.opacity(0.5), radius: 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                EmptyView()
            }
                
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(viewModel.remainingDaysString)
                    .font(AppFont.mainNumber)
                    .foregroundColor(numberColor)
                    .id(viewModel.remainingDaysString)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                
                Text("天")
                    .font(AppFont.dayUnit)
                    .foregroundColor(AppColor.secondaryText)
            }
            .shadow(color: numberColor.opacity(viewModel.status == .unreset ? 0.04 : 0.18), radius: 10)
        }
    }
    
    private var trailingNode: some View {
        let angle = (-90 + Double(progressValue) * 360) * .pi / 180
        let radius = AppSize.countdownRingSize / 2
        let x = CGFloat(cos(angle)) * radius
        let y = CGFloat(sin(angle)) * radius
        
        return Circle()
            .fill(primaryRingColor)
            .frame(width: 8, height: 8)
            .shadow(color: primaryRingColor.opacity(0.65), radius: 6)
            .opacity(viewModel.status == .unreset ? 0 : 0.9)
            .offset(x: x, y: y)
    }
    
    private var particles: some View {
        ZStack {
            orbitParticle(index: 0, angle: -138, radius: 109, size: 9)
            orbitParticle(index: 1, angle: -117, radius: 102, size: 5)
            orbitParticle(index: 2, angle: -96, radius: 118, size: 4)
            orbitParticle(index: 3, angle: -42, radius: 112, size: 5)
            orbitParticle(index: 4, angle: 144, radius: 119, size: 8)
        }
        .opacity(viewModel.status == .unreset ? 0.28 : 0.74)
    }
    
    private func orbitParticle(index: Int, angle: Double, radius: CGFloat, size: CGFloat) -> some View {
        let radians = angle * .pi / 180
        let color = gradientColors[index % gradientColors.count]
        
        return Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        AppColor.primaryText.opacity(0.68),
                        color.opacity(0.86),
                        color.opacity(0.12)
                    ]),
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: size
                )
            )
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.32), radius: size * 0.8)
            .offset(x: CGFloat(cos(radians)) * radius, y: CGFloat(sin(radians)) * radius * 0.84)
    }
    
    private var ringTrim: CGFloat {
        viewModel.status == .resetting ? 0.82 : progressValue
    }
    
    private var progressValue: CGFloat {
        if viewModel.status == .unreset { return 1.0 }
        if viewModel.remainingDays <= 0 { return 0.015 }
        return min(1, CGFloat(viewModel.remainingDays) / 30.0)
    }
    
    private var gradientColors: [Color] {
        let colors = viewModel.status.ringColors
        guard let first = colors.first else { return [AppColor.electricCyan, AppColor.laserBlue, AppColor.violetPurple] }
        if colors.count == 1 {
            return [first.opacity(0.55), first, first.opacity(0.35), first.opacity(0.55)]
        }
        return colors + [first]
    }
    
    private var primaryRingColor: Color {
        gradientColors.first ?? AppColor.electricCyan
    }
    
    private var numberColor: Color {
        switch viewModel.status {
        case .unreset:
            return AppColor.primaryText.opacity(0.62)
        case .expired:
            return AppColor.dangerPinkRed
        case .success:
            return AppColor.softAqua
        default:
            return AppColor.primaryText
        }
    }
    
    private var glowOpacity: Double {
        switch viewModel.status {
        case .unreset:
            return 0.12
        case .success:
            return 0.48
        case .resetting:
            return 0.36
        default:
            return 0.26
        }
    }
}

private struct ResetProcessingOverlay: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.34)
                    .stroke(
                        AngularGradient(
                            colors: [
                                .clear,
                                AppColor.electricCyan.opacity(0.95),
                                AppColor.softAqua,
                                .clear
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: AppSize.countdownRingSize + 24, height: AppSize.countdownRingSize + 24)
                    .rotationEffect(.degrees(t * 220))
                    .shadow(color: AppColor.electricCyan.opacity(0.65), radius: 10)
                
                Circle()
                    .trim(from: 0.56, to: 0.72)
                    .stroke(AppColor.neonMagenta.opacity(0.75), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                    .frame(width: AppSize.countdownRingSize - 20, height: AppSize.countdownRingSize - 20)
                    .rotationEffect(.degrees(-t * 170))
                    .shadow(color: AppColor.neonMagenta.opacity(0.38), radius: 8)
                
                ForEach(0..<10, id: \.self) { index in
                    let angle = (Double(index) * 36 + t * 120) * .pi / 180
                    Capsule()
                        .fill(AppColor.electricCyan.opacity(index.isMultiple(of: 2) ? 0.5 : 0.22))
                        .frame(width: 2, height: index.isMultiple(of: 3) ? 18 : 11)
                        .offset(x: CGFloat(cos(angle)) * 122, y: CGFloat(sin(angle)) * 122)
                        .rotationEffect(.degrees(Double(index) * 36 + t * 120))
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                AppColor.softAqua.opacity(0.26),
                                AppColor.electricCyan.opacity(0.5),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 132, height: 2)
                    .offset(y: CGFloat(sin(t * 5.4)) * 42)
                    .blur(radius: 0.4)
            }
        }
        .allowsHitTesting(false)
    }
}
