using System;
using System.Windows;
using System.Windows.Media;
using System.Windows.Shapes;

namespace SibeliusReset.Controls
{
    /// <summary>
    /// A custom <see cref="Shape"/> that renders an arc segment.
    /// <para>
    /// Angles use a "clock" convention: <b>0° = top (12 o'clock)</b>,
    /// increasing <b>clockwise</b>. This matches the macOS SwiftUI convention
    /// used by the countdown ring.
    /// </para>
    /// </summary>
    public class ArcShape : Shape
    {
        // ── Dependency Properties ────────────────────────────────────

        /// <summary>
        /// Start angle in degrees. 0 = top, clockwise.
        /// </summary>
        public static readonly DependencyProperty StartAngleProperty =
            DependencyProperty.Register(
                nameof(StartAngle),
                typeof(double),
                typeof(ArcShape),
                new FrameworkPropertyMetadata(
                    0.0,
                    FrameworkPropertyMetadataOptions.AffectsRender |
                    FrameworkPropertyMetadataOptions.AffectsMeasure));

        /// <summary>
        /// End angle in degrees. 0 = top, clockwise.
        /// </summary>
        public static readonly DependencyProperty EndAngleProperty =
            DependencyProperty.Register(
                nameof(EndAngle),
                typeof(double),
                typeof(ArcShape),
                new FrameworkPropertyMetadata(
                    360.0,
                    FrameworkPropertyMetadataOptions.AffectsRender |
                    FrameworkPropertyMetadataOptions.AffectsMeasure));

        public double StartAngle
        {
            get => (double)GetValue(StartAngleProperty);
            set => SetValue(StartAngleProperty, value);
        }

        public double EndAngle
        {
            get => (double)GetValue(EndAngleProperty);
            set => SetValue(EndAngleProperty, value);
        }

        // ── DefiningGeometry ─────────────────────────────────────────

        protected override Geometry DefiningGeometry
        {
            get
            {
                double width  = ActualWidth  > 0 ? ActualWidth  : Width;
                double height = ActualHeight > 0 ? ActualHeight : Height;

                if (double.IsNaN(width)  || width  <= 0 ||
                    double.IsNaN(height) || height <= 0)
                {
                    return Geometry.Empty;
                }

                double strokeHalf = StrokeThickness / 2.0;
                double rx = (width  / 2.0) - strokeHalf;
                double ry = (height / 2.0) - strokeHalf;

                if (rx <= 0 || ry <= 0)
                    return Geometry.Empty;

                var center = new Point(width / 2.0, height / 2.0);

                // Normalize the sweep so we know how much arc to draw.
                double sweep = NormalizeSweep(EndAngle - StartAngle);

                // Edge case: zero sweep → nothing to draw.
                if (Math.Abs(sweep) < 0.001)
                    return Geometry.Empty;

                // Edge case: full circle (≥ 360°).
                // ArcSegment cannot represent a complete ellipse, so we use
                // an EllipseGeometry instead.
                if (sweep >= 359.999)
                {
                    var ellipse = new EllipseGeometry(center, rx, ry);
                    ellipse.Freeze();
                    return ellipse;
                }

                // Convert our clock-convention angles to standard math radians.
                // Clock: 0°=top, CW  →  Math: 0°=right, CCW
                //   mathAngle = 90° − clockAngle  (then negate for CW in screen coords)
                // In WPF screen coords (Y-down), clockwise in our convention is
                // the same as the positive-angle direction for ArcSegment (SweepDirection.Clockwise),
                // so we just need to map the start/end points.
                Point startPoint = AngleToPoint(StartAngle, rx, ry, center);
                Point endPoint   = AngleToPoint(StartAngle + sweep, rx, ry, center);

                bool isLargeArc = sweep > 180.0;

                var arcSegment = new ArcSegment
                {
                    Point          = endPoint,
                    Size           = new Size(rx, ry),
                    IsLargeArc     = isLargeArc,
                    SweepDirection = SweepDirection.Clockwise,
                    IsStroked      = true
                };

                var figure = new PathFigure
                {
                    StartPoint = startPoint,
                    IsClosed   = false,
                    IsFilled   = false
                };
                figure.Segments.Add(arcSegment);

                var geometry = new PathGeometry();
                geometry.Figures.Add(figure);
                geometry.Freeze();

                return geometry;
            }
        }

        // ── Helpers ──────────────────────────────────────────────────

        /// <summary>
        /// Maps a clock-convention angle (0° = top, CW) to a point on the ellipse.
        /// </summary>
        private static Point AngleToPoint(double clockAngle, double rx, double ry, Point center)
        {
            // Convert clock angle to standard math radians:
            //   In clock convention 0° is at the top (negative Y direction in screen coords).
            //   Rotation is clockwise in screen coords.
            //   Standard math: 0° is at the right (+X), CCW is positive.
            //   Mapping: mathAngle = clockAngle − 90°  (for CW in screen coords)
            double radians = (clockAngle - 90.0) * Math.PI / 180.0;
            return new Point(
                center.X + rx * Math.Cos(radians),
                center.Y + ry * Math.Sin(radians));
        }

        /// <summary>
        /// Normalizes a sweep angle to [0, 360].
        /// </summary>
        private static double NormalizeSweep(double sweep)
        {
            // Modulo into (-360, 360) then shift to [0, 360).
            sweep %= 360.0;
            if (sweep < 0) sweep += 360.0;
            return sweep;
        }
    }
}
