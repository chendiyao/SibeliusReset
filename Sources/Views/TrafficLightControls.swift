import SwiftUI
import AppKit

struct TrafficLightControls: View {
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 8) {
            trafficButton(color: Color(nsColor: NSColor(hex: "#FF5F57") ?? .systemRed), symbol: "xmark", help: "关闭") {
                activeWindow?.close()
            }
            
            trafficButton(color: Color(nsColor: NSColor(hex: "#FFBD2E") ?? .systemYellow), symbol: "minus", help: "最小化") {
                activeWindow?.miniaturize(nil)
            }
            
            trafficButton(color: Color(nsColor: NSColor(hex: "#28C840") ?? .systemGreen), symbol: "plus", help: "居中窗口") {
                activeWindow?.center()
            }
        }
        .padding(6)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }
    
    private func trafficButton(color: Color, symbol: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 6.5, weight: .bold))
                        .foregroundColor(.black.opacity(0.42))
                        .opacity(isHovered ? 1 : 0)
                )
                .shadow(color: color.opacity(0.28), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .help(help)
    }
    
    private var activeWindow: NSWindow? {
        NSApp.keyWindow ?? NSApp.windows.first(where: { $0.isVisible })
    }
}
