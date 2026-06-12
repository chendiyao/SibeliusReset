import SwiftUI
import AppKit

enum AppStatus: Equatable {
    case unreset
    case normal
    case fewDaysLeft
    case expiringSoon
    case expired
    case resetting
    case success

    var text: String {
        switch self {
        case .unreset: return "等待首次重置"
        case .normal: return "状态正常"
        case .fewDaysLeft: return "剩余时间较少"
        case .expiringSoon: return "即将到期"
        case .expired: return "已到期"
        case .resetting: return "重置中..."
        case .success: return "本次重置已完成"
        }
    }

    var ringColors: [Color] {
        switch self {
        case .unreset: return [AppColor.mutedText.opacity(0.3)]
        case .normal, .success: return [AppColor.electricCyan, AppColor.laserBlue, AppColor.violetPurple]
        case .fewDaysLeft: return [AppColor.laserBlue, AppColor.violetPurple, AppColor.warningAmber]
        case .expiringSoon: return [AppColor.violetPurple, AppColor.neonMagenta, AppColor.warningAmber]
        case .expired: return [AppColor.neonMagenta.opacity(0.5), AppColor.dangerPinkRed]
        case .resetting: return [AppColor.electricCyan, AppColor.softAqua]
        }
    }
}

class ResetViewModel: ObservableObject {
    @AppStorage("lastResetDate") var lastResetDate: Double = 0
    @Published var status: AppStatus = .unreset
    @Published var remainingDaysString: String = "--"
    @Published var remainingDays: Int = -1
    private let resetCompletionAnimationDelay: TimeInterval = 1.6
    private let completionSound = NSSound(named: NSSound.Name("Glass"))
    private var resetTargets: [ResetTarget] {
        [
            ResetTarget(label: "Sibelius 试用记录", path: "/Applications/APi1"),
            ResetTarget(label: "Avid 授权缓存", path: "/Library/Application Support/Avid/Sibelius/_manuscript/ACr2"),
            ResetTarget(label: "Sibelius 插件缓存", path: "/Library/Application Support/Avid/Sibelius/_manuscript/Plugins_v2"),
            ResetTarget(
                label: "当前用户试用缓存",
                path: FileManager.default.homeDirectoryForCurrentUser
                    .appendingPathComponent("Library/Application Support/Avid/Sibelius/_manuscript/HEa3")
                    .path
            )
        ]
    }
    
    init() {
        updateState()
    }

    func updateState() {
        if lastResetDate == 0 {
            status = .unreset
            remainingDaysString = "--"
            remainingDays = -1
            return
        }

        let resetDate = Date(timeIntervalSince1970: lastResetDate)
        let expireDate = expirationDate(from: resetDate)
        let now = Date()

        let days = max(0, Int(ceil(expireDate.timeIntervalSince(now) / 86_400)))
        remainingDays = days
        remainingDaysString = "\(days)"

        if days >= 11 {
            status = .normal
        } else if days >= 6 {
            status = .fewDaysLeft
        } else if days >= 1 {
            status = .expiringSoon
        } else {
            status = .expired
        }
    }

    func performReset() {
        guard status != .resetting else { return }

        withAnimation(AppMotion.statusChange) {
            status = .resetting
        }

        let targets = resetTargets

        DispatchQueue.global(qos: .userInitiated).async {
            let deleteCommand = "/bin/rm -rf -- " + targets
                .map { Self.shellQuoted($0.path) }
                .joined(separator: " ")
            let scriptSource = """
            do shell script "\(Self.appleScriptEscaped(deleteCommand))" with administrator privileges
            """

            var error: NSDictionary?
            guard let scriptObject = NSAppleScript(source: scriptSource) else {
                DispatchQueue.main.async {
                    self.failReset(message: "无法创建系统授权脚本，请重新打开应用后再试。")
                }
                return
            }

            _ = scriptObject.executeAndReturnError(&error)

            if let err = error {
                DispatchQueue.main.async {
                    self.failReset(message: Self.appleScriptErrorMessage(err))
                }
                return
            }

            let remainingTargets = targets.filter { FileManager.default.fileExists(atPath: $0.path) }
            guard remainingTargets.isEmpty else {
                let names = remainingTargets.map(\.label).joined(separator: "、")
                DispatchQueue.main.async {
                    self.failReset(message: "以下项目未能清理完成：\(names)。请确认没有正在运行 Sibelius 或 Avid 相关程序后重试。")
                }
                return
            }

            DispatchQueue.main.async {
                self.completeReset()
            }
        }
    }
    
    var lastResetDateString: String {
        if lastResetDate == 0 { return "--" }
        return formattedDate(Date(timeIntervalSince1970: lastResetDate))
    }
    
    var nextExpireDateString: String {
        if lastResetDate == 0 { return "--" }
        let resetDate = Date(timeIntervalSince1970: lastResetDate)
        let expireDate = expirationDate(from: resetDate)
        return formattedDate(expireDate)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func playCompletionSound() {
        guard let completionSound else {
            NSSound.beep()
            return
        }
        
        completionSound.stop()
        completionSound.volume = 0.58
        completionSound.play()
    }

    private func completeReset() {
        lastResetDate = Date().timeIntervalSince1970
        withAnimation(AppMotion.softSpring) {
            updateState()
            status = .resetting
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + resetCompletionAnimationDelay) {
            withAnimation(AppMotion.softSpring) {
                self.status = .success
            }
            self.playCompletionSound()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + resetCompletionAnimationDelay + 1.2) {
            withAnimation(AppMotion.statusChange) {
                self.updateState()
            }
        }
    }

    private func failReset(message: String) {
        withAnimation(AppMotion.statusChange) {
            updateState()
        }
        showResetError(message)
    }

    private func showResetError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "重置未完成"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "知道了")
        alert.runModal()
    }

    private func expirationDate(from resetDate: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 30, to: resetDate)
            ?? resetDate.addingTimeInterval(30 * 86_400)
    }

    private static func appleScriptErrorMessage(_ error: NSDictionary) -> String {
        if let message = error[NSAppleScript.errorMessage] as? String, !message.isEmpty {
            return message
        }
        return "系统授权失败或用户取消了密码输入。"
    }

    private static func shellQuoted(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private static func appleScriptEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

private struct ResetTarget {
    let label: String
    let path: String
}
