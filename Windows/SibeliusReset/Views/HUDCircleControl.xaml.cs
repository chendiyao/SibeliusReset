using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Animation;
using SibeliusReset.ViewModels;

namespace SibeliusReset.Views
{
    public partial class HUDCircleControl : UserControl
    {
        private ResetViewModel? _viewModel;
        private Storyboard? _spinStoryboard;

        public HUDCircleControl()
        {
            InitializeComponent();
            DataContextChanged += OnDataContextChanged;
            Loaded += OnLoaded;
        }

        private void OnLoaded(object sender, RoutedEventArgs e)
        {
            _spinStoryboard = (Storyboard)FindResource("SpinStoryboard");
            UpdateDisplay();
        }

        private void OnDataContextChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
            if (_viewModel != null)
                _viewModel.PropertyChanged -= OnViewModelPropertyChanged;

            _viewModel = e.NewValue as ResetViewModel;

            if (_viewModel != null)
                _viewModel.PropertyChanged += OnViewModelPropertyChanged;

            UpdateDisplay();
        }

        private void OnViewModelPropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                if (e.PropertyName == nameof(ResetViewModel.RemainingDays) ||
                    e.PropertyName == nameof(ResetViewModel.Status))
                {
                    UpdateDisplay();
                }

                if (e.PropertyName == nameof(ResetViewModel.IsResetting))
                {
                    UpdateResettingState();
                }
            });
        }

        private void UpdateDisplay()
        {
            if (_viewModel == null) return;

            int days = _viewModel.RemainingDays;
            double progress = Math.Clamp(days / 30.0, 0.0, 1.0);
            double endAngle = -90 + (progress * 360);

            ProgressArc.EndAngle = endAngle;
            ProgressGlow.EndAngle = endAngle;

            // Update trailing node position
            if (progress > 0.01)
            {
                TrailingNode.Visibility = Visibility.Visible;
                double angleRad = endAngle * Math.PI / 180.0;
                double radius = 105; // half of 210
                double cx = 124;     // center X of 248
                double cy = 124;     // center Y of 248
                double nx = cx + radius * Math.Cos(angleRad) - 5; // -5 for half node size
                double ny = cy + radius * Math.Sin(angleRad) - 5;
                NodeTranslate.X = nx;
                NodeTranslate.Y = ny;
            }
            else
            {
                TrailingNode.Visibility = Visibility.Collapsed;
            }

            UpdateResettingState();
        }

        private void UpdateResettingState()
        {
            if (_viewModel == null) return;

            if (_viewModel.IsResetting)
            {
                ResettingOverlay.Visibility = Visibility.Visible;
                _spinStoryboard?.Begin();
            }
            else
            {
                ResettingOverlay.Visibility = Visibility.Collapsed;
                _spinStoryboard?.Stop();
            }
        }
    }
}
