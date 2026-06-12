using System;
using System.Windows.Input;

namespace SibeliusReset.Core
{
    /// <summary>
    /// A lightweight <see cref="ICommand"/> implementation that delegates execution
    /// and can-execute logic to caller-supplied delegates.
    /// <para>
    /// <see cref="CanExecuteChanged"/> is wired to
    /// <see cref="CommandManager.RequerySuggested"/> so the UI automatically
    /// re-evaluates button enabled states whenever WPF deems it necessary.
    /// </para>
    /// </summary>
    public class RelayCommand : ICommand
    {
        private readonly Action<object?> _execute;
        private readonly Func<object?, bool>? _canExecute;

        // ── Constructors ─────────────────────────────────────────────

        /// <summary>
        /// Creates a <see cref="RelayCommand"/> with both execute and can-execute delegates.
        /// </summary>
        /// <param name="execute">Action to run when the command is invoked.</param>
        /// <param name="canExecute">
        /// Predicate that determines whether the command can execute.
        /// Pass <c>null</c> to always allow execution.
        /// </param>
        public RelayCommand(Action<object?> execute, Func<object?, bool>? canExecute = null)
        {
            _execute = execute ?? throw new ArgumentNullException(nameof(execute));
            _canExecute = canExecute;
        }

        /// <summary>
        /// Convenience: creates a parameterless <see cref="RelayCommand"/>.
        /// </summary>
        /// <param name="execute">Action to run (parameter is ignored).</param>
        /// <param name="canExecute">
        /// Optional predicate (parameter is ignored).
        /// </param>
        public RelayCommand(Action execute, Func<bool>? canExecute = null)
            : this(
                _ => execute(),
                canExecute is null ? null : _ => canExecute())
        {
            if (execute is null) throw new ArgumentNullException(nameof(execute));
        }

        // ── ICommand ─────────────────────────────────────────────────

        /// <summary>
        /// Raised when the return value of <see cref="CanExecute"/> may have changed.
        /// Delegates to <see cref="CommandManager.RequerySuggested"/> so WPF
        /// automatically invalidates command bindings at the right time.
        /// </summary>
        public event EventHandler? CanExecuteChanged
        {
            add    => CommandManager.RequerySuggested += value;
            remove => CommandManager.RequerySuggested -= value;
        }

        /// <inheritdoc />
        public bool CanExecute(object? parameter)
        {
            return _canExecute?.Invoke(parameter) ?? true;
        }

        /// <inheritdoc />
        public void Execute(object? parameter)
        {
            _execute(parameter);
        }

        /// <summary>
        /// Forces WPF to re-query all command bindings.
        /// Call this after any state change that affects <see cref="CanExecute"/>.
        /// </summary>
        public static void RaiseCanExecuteChanged()
        {
            CommandManager.InvalidateRequerySuggested();
        }
    }
}
