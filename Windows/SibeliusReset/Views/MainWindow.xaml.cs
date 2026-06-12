using System.Windows;
using System.Windows.Input;
using SibeliusReset.ViewModels;

namespace SibeliusReset.Views
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            DataContext = new ResetViewModel();
        }

        private void TitleBar_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ClickCount == 1)
                DragMove();
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        private void MinimizeButton_Click(object sender, RoutedEventArgs e)
        {
            WindowState = WindowState.Minimized;
        }

        private void HelpButton_Click(object sender, RoutedEventArgs e)
        {
            HelpOverlayControl.Visibility = Visibility.Visible;
        }

        private void HelpOverlay_Closed(object sender, System.EventArgs e)
        {
            HelpOverlayControl.Visibility = Visibility.Collapsed;
        }
    }
}
