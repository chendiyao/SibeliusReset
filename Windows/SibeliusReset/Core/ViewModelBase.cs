using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace SibeliusReset.Core
{
    /// <summary>
    /// Base class for all view models, providing <see cref="INotifyPropertyChanged"/> support.
    /// </summary>
    public abstract class ViewModelBase : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler? PropertyChanged;

        /// <summary>
        /// Raises the <see cref="PropertyChanged"/> event for the specified property.
        /// When called without arguments from a property setter, the compiler supplies the
        /// property name automatically via <see cref="CallerMemberNameAttribute"/>.
        /// </summary>
        /// <param name="propertyName">
        /// Name of the property that changed. Supplied automatically by the compiler
        /// when omitted.
        /// </param>
        protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        /// <summary>
        /// Sets the backing field to <paramref name="value"/> and raises
        /// <see cref="PropertyChanged"/> if the value actually changed.
        /// </summary>
        /// <typeparam name="T">Type of the property.</typeparam>
        /// <param name="field">Reference to the backing field.</param>
        /// <param name="value">New value to assign.</param>
        /// <param name="propertyName">
        /// Name of the property. Supplied automatically by the compiler when omitted.
        /// </param>
        /// <returns>
        /// <c>true</c> if the value changed and the event was raised; otherwise <c>false</c>.
        /// </returns>
        protected bool SetProperty<T>(
            ref T field,
            T value,
            [CallerMemberName] string? propertyName = null)
        {
            if (Equals(field, value))
                return false;

            field = value;
            OnPropertyChanged(propertyName);
            return true;
        }
    }
}
