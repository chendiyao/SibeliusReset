import SwiftUI

@main
struct SibeliusResetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
                .onAppear {
                    DispatchQueue.main.async {
                        NSApplication.shared.windows.first?.applyResetToolStyle()
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("关于 \(AppIdentity.displayName)") {
                    NSApp.orderFrontStandardAboutPanel(options: .sibeliusResetAboutOptions)
                }
            }
            CommandGroup(replacing: .newItem, addition: { })
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        localizeMainMenu()
        DispatchQueue.main.async {
            self.localizeMainMenu()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func localizeMainMenu() {
        NSApp.mainMenu?.localizeForSibeliusReset()
    }
}

private extension Dictionary where Key == NSApplication.AboutPanelOptionKey, Value == Any {
    static var sibeliusResetAboutOptions: Self {
        [
            .applicationName: AppIdentity.displayName,
            .credits: NSAttributedString.sibeliusResetCredits
        ]
    }
}

private extension NSAttributedString {
    static var sibeliusResetCredits: NSAttributedString {
        let text = "作者：YOYO\n微信：audioba\n编曲资源网：audioba.com"
        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: attributed.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        
        attributed.addAttributes([
            .font: NSFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)
        
        let linkRange = (text as NSString).range(of: "audioba.com")
        attributed.addAttributes([
            .link: URL(string: "https://audioba.com")!,
            .foregroundColor: NSColor.linkColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: linkRange)
        
        return attributed
    }
}

private extension NSWindow {
    func applyResetToolStyle() {
        title = AppIdentity.displayName
        styleMask = [.borderless, .miniaturizable]
        isMovableByWindowBackground = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        collectionBehavior.remove(.fullScreenPrimary)
        
        let size = NSSize(width: AppSize.windowWidth, height: AppSize.windowHeight)
        minSize = size
        maxSize = size
        setContentSize(size)
        center()
    }
}

private extension NSMenu {
    func localizeForSibeliusReset() {
        for item in items {
            item.title = item.title.localizedMenuTitle
            item.submenu?.localizeForSibeliusReset()
        }
    }
}

private extension String {
    var localizedMenuTitle: String {
        let appName = AppIdentity.displayName
        let replacements: [String: String] = [
            "Sibelius Reset": appName,
            "About Sibelius Reset": "关于 \(appName)",
            "Edit": "编辑",
            "View": "视图",
            "Window": "窗口",
            "Help": "帮助",
            "Services": "服务",
            "Hide Sibelius Reset": "隐藏 \(appName)",
            "Hide Others": "隐藏其他",
            "Show All": "全部显示",
            "Quit Sibelius Reset": "退出 \(appName)",
            "Undo": "撤销",
            "Redo": "重做",
            "Cut": "剪切",
            "Copy": "复制",
            "Paste": "粘贴",
            "Paste and Match Style": "粘贴并匹配样式",
            "Delete": "删除",
            "Select All": "全选",
            "Find": "查找",
            "Find...": "查找...",
            "Find and Replace...": "查找与替换...",
            "Find Next": "查找下一个",
            "Find Previous": "查找上一个",
            "Use Selection for Find": "使用所选内容查找",
            "Jump to Selection": "跳到所选内容",
            "Spelling and Grammar": "拼写与语法",
            "Show Spelling and Grammar": "显示拼写与语法",
            "Check Document Now": "立即检查文稿",
            "Check Spelling While Typing": "输入时检查拼写",
            "Check Grammar With Spelling": "随拼写检查语法",
            "Correct Spelling Automatically": "自动更正拼写",
            "Substitutions": "替换",
            "Show Substitutions": "显示替换",
            "Smart Copy/Paste": "智能复制/粘贴",
            "Smart Quotes": "智能引号",
            "Smart Dashes": "智能破折号",
            "Smart Links": "智能链接",
            "Data Detectors": "数据检测器",
            "Text Replacement": "文本替换",
            "Transformations": "转换",
            "Make Upper Case": "转为大写",
            "Make Lower Case": "转为小写",
            "Capitalize": "首字母大写",
            "Speech": "语音",
            "Start Speaking": "开始朗读",
            "Stop Speaking": "停止朗读",
            "Start Dictation...": "开始听写...",
            "Emoji & Symbols": "表情与符号",
            "Enter Full Screen": "进入全屏幕",
            "Minimize": "最小化",
            "Zoom": "缩放",
            "Bring All to Front": "全部移到前面",
            "Sibelius Reset Help": "\(appName) 帮助"
        ]
        
        return replacements[self] ?? replacingOccurrences(of: "Sibelius Reset", with: appName)
    }
}
