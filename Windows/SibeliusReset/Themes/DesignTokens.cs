using System;
using System.Windows.Media;

namespace SibeliusReset.Themes
{
    /// <summary>
    /// Application identity constants.
    /// </summary>
    public static class AppIdentity
    {
        public const string DisplayName = "Sibelius重置";
    }

    /// <summary>
    /// Application color palette ported from the macOS SwiftUI design.
    /// All colors are defined as <see cref="Color"/> properties with corresponding
    /// <see cref="SolidColorBrush"/> helpers via the <see cref="Brush"/> method.
    /// </summary>
    public static class AppColor
    {
        // ── Backgrounds ──────────────────────────────────────────────

        public static Color DeepSpaceBlack  => ColorFromHex("#050A18");
        public static Color MidnightNavy    => ColorFromHex("#08111F");
        public static Color PanelBlueBlack  => ColorFromHex("#101A33");

        // ── Accent / Brand ───────────────────────────────────────────

        public static Color ElectricCyan    => ColorFromHex("#38E8FF");
        public static Color LaserBlue       => ColorFromHex("#297BFF");
        public static Color VioletPurple    => ColorFromHex("#7B61FF");
        public static Color NeonMagenta     => ColorFromHex("#FF4DFF");
        public static Color SoftAqua        => ColorFromHex("#7DF9FF");

        // ── Text ─────────────────────────────────────────────────────

        public static Color PrimaryText     => ColorFromHex("#F4F7FF");
        public static Color SecondaryText   => ColorFromHex("#A9B6D3");
        public static Color MutedText       => ColorFromHex("#6F7EA3");

        // ── Semantic ─────────────────────────────────────────────────

        public static Color WarningAmber    => ColorFromHex("#FFCC66");
        public static Color DangerPinkRed   => ColorFromHex("#FF5C8A");

        // ── Helpers ──────────────────────────────────────────────────

        /// <summary>
        /// Creates a frozen <see cref="SolidColorBrush"/> from the given <see cref="Color"/>.
        /// Freezing the brush improves rendering performance in WPF.
        /// </summary>
        public static SolidColorBrush Brush(Color color)
        {
            var brush = new SolidColorBrush(color);
            brush.Freeze();
            return brush;
        }

        /// <summary>
        /// Parses a hex color string (e.g. "#FF5C8A" or "#80FF5C8A") into a <see cref="Color"/>.
        /// Supports #RGB, #RRGGBB, and #AARRGGBB formats.
        /// </summary>
        public static Color ColorFromHex(string hex)
        {
            if (string.IsNullOrWhiteSpace(hex))
                throw new ArgumentException("Hex color string must not be null or empty.", nameof(hex));

            hex = hex.TrimStart('#');

            byte a = 255, r, g, b;

            switch (hex.Length)
            {
                case 3: // #RGB
                    r = Convert.ToByte(new string(hex[0], 2), 16);
                    g = Convert.ToByte(new string(hex[1], 2), 16);
                    b = Convert.ToByte(new string(hex[2], 2), 16);
                    break;
                case 6: // #RRGGBB
                    r = Convert.ToByte(hex.Substring(0, 2), 16);
                    g = Convert.ToByte(hex.Substring(2, 2), 16);
                    b = Convert.ToByte(hex.Substring(4, 2), 16);
                    break;
                case 8: // #AARRGGBB
                    a = Convert.ToByte(hex.Substring(0, 2), 16);
                    r = Convert.ToByte(hex.Substring(2, 2), 16);
                    g = Convert.ToByte(hex.Substring(4, 2), 16);
                    b = Convert.ToByte(hex.Substring(6, 2), 16);
                    break;
                default:
                    throw new FormatException($"Invalid hex color format: #{hex}");
            }

            return Color.FromArgb(a, r, g, b);
        }
    }

    /// <summary>
    /// Application sizing constants for window, controls, and layout elements.
    /// Values are in device-independent pixels (DIPs).
    /// </summary>
    public static class AppSize
    {
        // ── Window ───────────────────────────────────────────────────

        public const double WindowWidth  = 420;
        public const double WindowHeight = 520;
        public const double WindowRadius = 28;

        // ── Info Panel ───────────────────────────────────────────────

        public const double InfoPanelRadius = 18;
        public const double InfoPanelWidth  = 340;
        public const double InfoPanelHeight = 72;

        // ── Buttons ──────────────────────────────────────────────────

        public const double ButtonRadius       = 32;
        public const double PrimaryButtonWidth  = 300;
        public const double PrimaryButtonHeight = 56;

        // ── Countdown Ring ───────────────────────────────────────────

        public const double CountdownOuterSize = 248;
        public const double CountdownRingSize  = 210;
        public const double CountdownInnerSize = 162;
    }
}
