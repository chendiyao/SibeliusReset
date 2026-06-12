using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace SibeliusReset.Views
{
    public partial class HelpOverlay : UserControl
    {
        public event EventHandler? Closed;

        public HelpOverlay()
        {
            InitializeComponent();
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Closed?.Invoke(this, EventArgs.Empty);
        }

        private void Background_Click(object sender, MouseButtonEventArgs e)
        {
            Closed?.Invoke(this, EventArgs.Empty);
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            Closed?.Invoke(this, EventArgs.Empty);
        }

        private void Website_Click(object sender, MouseButtonEventArgs e)
        {
            try
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = "https://audioba.com",
                    UseShellExecute = true
                });
            }
            catch (Exception)
            {
                // Silently handle if browser cannot be opened
            }
        }
    }
}
