using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;
using SibeliusReset.ViewModels;

namespace SibeliusReset.Converters
{
    /// <summary>
    /// Converts an <see cref="AppStatus"/> value to <see cref="Visibility"/>.
    /// <para>
    /// The converter parameter should be a comma-separated list of <see cref="AppStatus"/>
    /// member names (e.g. <c>"Normal,FewDaysLeft"</c>).  If the bound value matches any of
    /// the listed statuses the converter returns <see cref="Visibility.Visible"/>;
    /// otherwise <see cref="Visibility.Collapsed"/>.
    /// </para>
    /// </summary>
    public class StatusToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is not AppStatus status || parameter is not string param)
                return Visibility.Collapsed;

            var targets = param.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            foreach (var target in targets)
            {
                if (Enum.TryParse<AppStatus>(target.Trim(), ignoreCase: true, out var parsed)
                    && parsed == status)
                {
                    return Visibility.Visible;
                }
            }

            return Visibility.Collapsed;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }

    /// <summary>
    /// Converts a <see cref="bool"/> to <see cref="Visibility"/>.
    /// <c>true</c> → <see cref="Visibility.Visible"/>,
    /// <c>false</c> → <see cref="Visibility.Collapsed"/>.
    /// </summary>
    public class BoolToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value is true ? Visibility.Visible : Visibility.Collapsed;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value is Visibility.Visible;
        }
    }

    /// <summary>
    /// Inverse of <see cref="BoolToVisibilityConverter"/>.
    /// <c>true</c> → <see cref="Visibility.Collapsed"/>,
    /// <c>false</c> → <see cref="Visibility.Visible"/>.
    /// </summary>
    public class InverseBoolToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value is true ? Visibility.Collapsed : Visibility.Visible;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value is Visibility.Collapsed;
        }
    }

    /// <summary>
    /// Converts an <see cref="AppStatus"/> value to a <see cref="System.Windows.Media.SolidColorBrush"/>
    /// for status-dependent coloring in the UI.
    /// </summary>
    public class StatusToColorConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is not AppStatus status)
                return new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White);

            var color = status switch
            {
                AppStatus.Normal => Themes.AppColor.ElectricCyan,
                AppStatus.FewDaysLeft => Themes.AppColor.WarningAmber,
                AppStatus.ExpiringSoon => Themes.AppColor.DangerPinkRed,
                AppStatus.Expired => Themes.AppColor.DangerPinkRed,
                AppStatus.Resetting => Themes.AppColor.VioletPurple,
                AppStatus.Success => Themes.AppColor.ElectricCyan,
                _ => Themes.AppColor.MutedText
            };

            var brush = new System.Windows.Media.SolidColorBrush(color);
            brush.Freeze();
            return brush;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
}
