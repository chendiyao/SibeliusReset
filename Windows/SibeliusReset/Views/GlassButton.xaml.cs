using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media.Animation;
using SibeliusReset.ViewModels;

namespace SibeliusReset.Views
{
    public partial class GlassButton : UserControl
    {
        private Storyboard? _sweepStoryboard;
        private ResetViewModel? _viewModel;

        public static readonly DependencyProperty ButtonTitleProperty =
            DependencyProperty.Register(nameof(ButtonTitle), typeof(string), typeof(GlassButton),
                new PropertyMetadata("重置试用"));

        public static readonly DependencyProperty ButtonCommandProperty =
            DependencyProperty.Register(nameof(ButtonCommand), typeof(ICommand), typeof(GlassButton),
                new PropertyMetadata(null));

        public static readonly DependencyProperty StatusProperty =
            DependencyProperty.Register(nameof(Status), typeof(object), typeof(GlassButton),
                new PropertyMetadata(null, OnStatusChanged));

        public string ButtonTitle
        {
            get => (string)GetValue(ButtonTitleProperty);
            set => SetValue(ButtonTitleProperty, value);
        }

        public ICommand? ButtonCommand
        {
            get => (ICommand?)GetValue(ButtonCommandProperty);
            set => SetValue(ButtonCommandProperty, value);
        }

        public object? Status
        {
            get => GetValue(StatusProperty);
            set => SetValue(StatusProperty, value);
        }

        public GlassButton()
        {
            InitializeComponent();
            Loaded += OnLoaded;
            DataContextChanged += OnDataContextChanged;
        }

        private void OnLoaded(object sender, RoutedEventArgs e)
        {
            _sweepStoryboard = (Storyboard)FindResource("SweepAnimation");
            UpdateStatusVisuals();
        }

        private void OnDataContextChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
            if (_viewModel != null)
                _viewModel.PropertyChanged -= OnViewModelPropertyChanged;

            _viewModel = e.NewValue as ResetViewModel;

            if (_viewModel != null)
                _viewModel.PropertyChanged += OnViewModelPropertyChanged;
        }

        private void OnViewModelPropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(ResetViewModel.IsResetting) ||
                e.PropertyName == nameof(ResetViewModel.Status))
            {
                Dispatcher.Invoke(UpdateStatusVisuals);
            }
        }

        private static void OnStatusChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is GlassButton button)
                button.UpdateStatusVisuals();
        }

        private void UpdateStatusVisuals()
        {
            if (_viewModel == null) return;

            // Update icon based on status
            var status = _viewModel.Status;
            string icon = status switch
            {
                AppStatus.Success => "✓",
                AppStatus.Resetting => "⟳",
                AppStatus.Expired => "⚡",
                AppStatus.ExpiringSoon => "⚠",
                _ => "⟳"
            };
            ButtonIcon.Text = icon;

            // Handle sweep animation for resetting state
            if (_viewModel.IsResetting)
            {
                SweepContainer.Visibility = Visibility.Visible;
                _sweepStoryboard?.Begin();
            }
            else
            {
                SweepContainer.Visibility = Visibility.Collapsed;
                _sweepStoryboard?.Stop();
            }
        }
    }
}
