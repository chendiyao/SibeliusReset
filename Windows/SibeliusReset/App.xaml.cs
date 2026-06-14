using System.Windows;

namespace SibeliusReset;

/// <summary>
/// App.xaml 的交互逻辑
/// </summary>
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        // Catch UI thread exceptions
        this.DispatcherUnhandledException += (s, args) =>
        {
            MessageBox.Show($"UI Thread Exception:\n{args.Exception.Message}\n\n{args.Exception.StackTrace}", "崩溃日志", MessageBoxButton.OK, MessageBoxImage.Error);
            args.Handled = true;
        };

        // Catch background thread exceptions
        AppDomain.CurrentDomain.UnhandledException += (s, args) =>
        {
            if (args.ExceptionObject is Exception ex)
            {
                MessageBox.Show($"Background Thread Exception:\n{ex.Message}\n\n{ex.StackTrace}", "崩溃日志", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        };
    }
}
