import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ResetViewModel()
    @State private var didAppear = false
    @State private var successPulse = false
    @State private var isShowingHelp = false
    
    var body: some View {
        ZStack {
            windowSurface
            
            VStack(spacing: 18) {
                header
                    .entrance(didAppear, delay: 0.05, y: -12, scale: 0.98)
                
                ZStack {
                    successPulseRing
                    HUDCircleView(viewModel: viewModel)
                }
                .entrance(didAppear, delay: 0.16, y: 18, scale: 0.9)
                
                GlassButton(
                    title: buttonTitle,
                    action: {
                        viewModel.performReset()
                    },
                    isEnabled: viewModel.status != .resetting,
                    status: viewModel.status
                )
                .entrance(didAppear, delay: 0.3, y: 16, scale: 0.96)
                
                InfoPanel(
                    lastResetDate: viewModel.lastResetDateString,
                    nextExpireDate: viewModel.nextExpireDateString
                )
                .entrance(didAppear, delay: 0.4, y: 14, scale: 0.98)
            }
            .padding(.top, 34)
            .padding(.bottom, 24)
            
            VStack {
                HStack {
                    TrafficLightControls()
                    Spacer()
                    HelpButton {
                        withAnimation(AppMotion.softSpring) {
                            isShowingHelp = true
                        }
                    }
                }
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 14)
            .entrance(didAppear, delay: 0.02, y: -6, scale: 1)
            
            if isShowingHelp {
                HelpOverlay {
                    withAnimation(AppMotion.softSpring) {
                        isShowingHelp = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .frame(width: AppSize.windowWidth, height: AppSize.windowHeight)
        .clipShape(RoundedRectangle(cornerRadius: AppSize.windowRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppSize.windowRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppColor.primaryText.opacity(0.18),
                            AppColor.electricCyan.opacity(0.28),
                            AppColor.violetPurple.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(didAppear ? 1 : 0.965)
        .opacity(didAppear ? 1 : 0)
        .background(Color.clear)
        .animation(AppMotion.statusChange, value: viewModel.status)
        .onAppear {
            withAnimation(AppMotion.entrance) {
                didAppear = true
            }
        }
        .onChange(of: viewModel.status) { newStatus in
            guard newStatus == .success else { return }
            successPulse = false
            withAnimation(.easeOut(duration: 0.82)) {
                successPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                successPulse = false
            }
        }
    }
    
    private var windowSurface: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColor.panelBlueBlack,
                    AppColor.midnightNavy,
                    AppColor.deepSpaceBlack
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColor.electricCyan.opacity(0.13),
                    AppColor.panelBlueBlack.opacity(0.18),
                    .clear
                ]),
                center: .topLeading,
                startRadius: 12,
                endRadius: 280
            )
            .blur(radius: 8)
            
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColor.neonMagenta.opacity(0.08),
                    AppColor.violetPurple.opacity(0.08),
                    .clear
                ]),
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 250
            )
            .blur(radius: 10)
            
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColor.primaryText.opacity(0.08),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 110)
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Text(AppIdentity.displayName)
                .font(AppFont.title)
                .foregroundColor(AppColor.primaryText)
                .shadow(color: AppColor.primaryText.opacity(0.18), radius: 10, x: 0, y: 0)
            Spacer()
        }
    }
    
    private var successPulseRing: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        AppColor.electricCyan.opacity(0.9),
                        AppColor.softAqua.opacity(0.6),
                        AppColor.violetPurple.opacity(0.35),
                        AppColor.electricCyan.opacity(0.9)
                    ],
                    center: .center
                ),
                lineWidth: 2
            )
            .frame(width: AppSize.countdownOuterSize + 18, height: AppSize.countdownOuterSize + 18)
            .scaleEffect(successPulse ? 1.18 : 0.82)
            .opacity(successPulse ? 0 : (viewModel.status == .success ? 0.78 : 0))
            .blur(radius: successPulse ? 8 : 0)
    }
    
    private var buttonTitle: String {
        switch viewModel.status {
        case .resetting:
            return "重置中"
        case .success:
            return "完成"
        default:
            return "立即重置"
        }
    }
}

private struct HelpButton: View {
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "questionmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isHovered ? AppColor.deepSpaceBlack : AppColor.primaryText)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(isHovered ? AppColor.electricCyan : AppColor.primaryText.opacity(0.08))
                )
                .overlay(
                    Circle()
                        .stroke(AppColor.primaryText.opacity(isHovered ? 0.08 : 0.18), lineWidth: 1)
                )
                .shadow(color: AppColor.electricCyan.opacity(isHovered ? 0.36 : 0.1), radius: isHovered ? 10 : 4)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AppMotion.softSpring) {
                isHovered = hovering
            }
        }
    }
}

private struct HelpOverlay: View {
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.46)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
            
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("使用方法")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(AppColor.primaryText)
                        
                        Text("试用到期时，用本工具快速重置并记录周期。")
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(AppColor.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColor.secondaryText)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(AppColor.primaryText.opacity(0.08)))
                            .overlay(Circle().stroke(AppColor.primaryText.opacity(0.12), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 12) {
                            HelpStep(number: "01", text: "西贝柳斯的试用期为 30 天。")
                            HelpStep(number: "02", text: "如果软件不能继续试用了，点击“立即重置”。")
                            HelpStep(number: "03", text: "系统会要求输入电脑密码，也就是电脑开机密码。")
                            HelpStep(number: "04", text: "输入后会自动重置，并记录上次重置时间和下次到期时间。")
                        }

                        Divider()
                            .overlay(AppColor.primaryText.opacity(0.12))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "message.fill")
                                    .foregroundColor(AppColor.electricCyan)
                                Text("有问题可咨询微信：")
                                    .foregroundColor(AppColor.secondaryText)
                                Text("audioba")
                                    .foregroundColor(AppColor.primaryText)
                                    .fontWeight(.semibold)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .foregroundColor(AppColor.electricCyan)
                                Text("下载音源插件音色访问：")
                                    .foregroundColor(AppColor.secondaryText)
                                Link("audioba.com", destination: URL(string: "https://audioba.com")!)
                                    .foregroundColor(AppColor.electricCyan)
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                            }
                        }
                        .font(.system(size: 14, weight: .medium, design: .default))
                    }
                }
                .frame(maxHeight: 274)

                Button(action: onClose) {
                    Text("返回")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(AppColor.deepSpaceBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 21, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.electricCyan, AppColor.softAqua],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .frame(width: 348)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppColor.panelBlueBlack.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColor.electricCyan.opacity(0.36),
                                        AppColor.violetPurple.opacity(0.24),
                                        AppColor.primaryText.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: AppColor.electricCyan.opacity(0.14), radius: 22, x: 0, y: 10)
            .shadow(color: .black.opacity(0.42), radius: 34, x: 0, y: 22)
        }
    }
}

private struct HelpStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.deepSpaceBlack)
                .frame(width: 30, height: 20)
                .background(Capsule().fill(AppColor.electricCyan))
            
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(AppColor.primaryText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension View {
    func entrance(_ isVisible: Bool, delay: Double, y: CGFloat, scale: CGFloat) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : y)
            .scaleEffect(isVisible ? 1 : scale)
            .animation(AppMotion.entrance.delay(delay), value: isVisible)
    }
}
