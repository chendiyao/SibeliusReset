using System.Windows;
using System.Windows.Controls;

namespace SibeliusReset.Views
{
    public partial class InfoPanel : UserControl
    {
        public static readonly DependencyProperty LastResetDateProperty =
            DependencyProperty.Register(nameof(LastResetDate), typeof(string), typeof(InfoPanel),
                new PropertyMetadata("--", OnDateChanged));

        public static readonly DependencyProperty NextExpireDateProperty =
            DependencyProperty.Register(nameof(NextExpireDate), typeof(string), typeof(InfoPanel),
                new PropertyMetadata("--", OnDateChanged));

        public string LastResetDate
        {
            get => (string)GetValue(LastResetDateProperty);
            set => SetValue(LastResetDateProperty, value);
        }

        public string NextExpireDate
        {
            get => (string)GetValue(NextExpireDateProperty);
            set => SetValue(NextExpireDateProperty, value);
        }

        public InfoPanel()
        {
            InitializeComponent();
        }

        private static void OnDateChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is InfoPanel panel)
                panel.UpdateTexts();
        }

        private void UpdateTexts()
        {
            LastResetText.Text = NormalizeDate(LastResetDate, "未重置");
            NextExpireText.Text = NormalizeDate(NextExpireDate, "重置后生成");
        }

        private static string NormalizeDate(string? value, string fallback)
        {
            if (string.IsNullOrEmpty(value) || value == "--")
                return fallback;
            return value;
        }
    }
}
