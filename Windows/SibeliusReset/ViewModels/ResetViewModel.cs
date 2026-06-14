using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Media;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using Microsoft.Win32;
using SibeliusReset.Core;
using SibeliusReset.Themes;

namespace SibeliusReset.ViewModels
{
    // ── AppStatus Enum ───────────────────────────────────────────

    /// <summary>
    /// Represents the application's current operational status.
    /// </summary>
    public enum AppStatus
    {
        /// <summary>Initial/unknown state — trial status has not been determined.</summary>
        Unreset,
        /// <summary>Plenty of trial days remaining.</summary>
        Normal,
        /// <summary>A few days left (≤ 7 days).</summary>
        FewDaysLeft,
        /// <summary>Expiring very soon (≤ 3 days).</summary>
        ExpiringSoon,
        /// <summary>Trial has expired (0 days).</summary>
        Expired,
        /// <summary>Reset operation is currently in progress.</summary>
        Resetting,
        /// <summary>Reset completed successfully.</summary>
        Success
    }

    // ── Settings DTO ─────────────────────────────────────────────

    /// <summary>
    /// Lightweight DTO persisted to <c>%APPDATA%/SibeliusReset/settings.json</c>.
    /// </summary>
    internal sealed class AppSettings
    {
        public DateTime? LastResetDate { get; set; }
    }

    // ── ViewModel ────────────────────────────────────────────────

    /// <summary>
    /// Primary view model for the Sibelius重置 application.
    /// Manages trial status detection, the reset workflow, and all
    /// UI-bound properties including ring colors and status text.
    /// </summary>
    public class ResetViewModel : ViewModelBase
    {
        // ── Constants ────────────────────────────────────────────

        /// <summary>Sibelius trial duration in days.</summary>
        private const int TrialDurationDays = 30;

        // ── Backing Fields ───────────────────────────────────────

        private AppStatus _status = AppStatus.Unreset;
        private string _remainingDaysString = "--";
        private int _remainingDays = -1;
        private string _lastResetDateString = "从未";
        private string _nextExpireDateString = "--";
        private bool _isResetting;
        private DateTime? _lastResetDate;

        // ── Constructor ──────────────────────────────────────────

        public ResetViewModel()
        {
            ResetCommand = new RelayCommand(
                execute:    _ => OnResetRequested(),
                canExecute: _ => !IsResetting);

            LoadSettings();
            RefreshStatus();
        }

        // ── Bindable Properties ──────────────────────────────────

        public AppStatus Status
        {
            get => _status;
            private set
            {
                if (SetProperty(ref _status, value))
                {
                    OnPropertyChanged(nameof(StatusText));
                    OnPropertyChanged(nameof(ButtonTitle));
                }
            }
        }

        public string RemainingDaysString
        {
            get => _remainingDaysString;
            private set => SetProperty(ref _remainingDaysString, value);
        }

        public int RemainingDays
        {
            get => _remainingDays;
            private set => SetProperty(ref _remainingDays, value);
        }

        public string LastResetDateString
        {
            get => _lastResetDateString;
            private set => SetProperty(ref _lastResetDateString, value);
        }

        public string NextExpireDateString
        {
            get => _nextExpireDateString;
            private set => SetProperty(ref _nextExpireDateString, value);
        }

        public string StatusText
        {
            get => _status switch
            {
                AppStatus.Unreset      => "就绪",
                AppStatus.Normal       => $"试用剩余 {RemainingDays} 天",
                AppStatus.FewDaysLeft  => $"即将到期，剩余 {RemainingDays} 天",
                AppStatus.ExpiringSoon => $"紧急！仅剩 {RemainingDays} 天",
                AppStatus.Expired      => "试用已过期",
                AppStatus.Resetting    => "正在重置…",
                AppStatus.Success      => "重置成功！",
                _                      => "就绪"
            };
        }

        public bool IsResetting
        {
            get => _isResetting;
            private set
            {
                if (SetProperty(ref _isResetting, value))
                    RelayCommand.RaiseCanExecuteChanged();
            }
        }

        public string ButtonTitle
        {
            get => _status switch
            {
                AppStatus.Resetting => "正在重置…",
                AppStatus.Success   => "重置成功",
                _                   => "重置试用"
            };
        }

        // ── Commands ─────────────────────────────────────────────

        public RelayCommand ResetCommand { get; }

        // ── Ring Colors ──────────────────────────────────────────

        /// <summary>
        /// Returns an array of <see cref="Color"/>s for the countdown ring
        /// gradient based on the current <see cref="Status"/>.
        /// </summary>
        public Color[] GetRingColors()
        {
            return _status switch
            {
                AppStatus.Normal =>
                    new[] { AppColor.ElectricCyan, AppColor.LaserBlue },

                AppStatus.FewDaysLeft =>
                    new[] { AppColor.WarningAmber, AppColor.LaserBlue },

                AppStatus.ExpiringSoon =>
                    new[] { AppColor.DangerPinkRed, AppColor.WarningAmber },

                AppStatus.Expired =>
                    new[] { AppColor.DangerPinkRed, AppColor.NeonMagenta },

                AppStatus.Success =>
                    new[] { AppColor.ElectricCyan, AppColor.VioletPurple, AppColor.NeonMagenta },

                AppStatus.Resetting =>
                    new[] { AppColor.VioletPurple, AppColor.NeonMagenta },

                _ => // Unreset / default
                    new[] { AppColor.MutedText, AppColor.SecondaryText }
            };
        }

        // ── Reset Workflow ───────────────────────────────────────

        private async void OnResetRequested()
        {
            IsResetting = true;
            Status = AppStatus.Resetting;

            try
            {
                await Task.Run(() => PerformReset());

                // Show "Resetting" for 1.6 s
                await Task.Delay(1600);

                Status = AppStatus.Success;
                SystemSounds.Asterisk.Play();

                // Persist the new reset date
                _lastResetDate = DateTime.Now;
                SaveSettings();
                RefreshStatus();

                // Keep "Success" visible for 1.2 s, then close the app
                await Task.Delay(1200);
                System.Windows.Application.Current.Shutdown();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"重置过程中出现错误:\n\n{ex.Message}",
                    AppIdentity.DisplayName,
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);

                RefreshStatus();
            }
            finally
            {
                IsResetting = false;
            }
        }

        // ── Core Reset Logic ─────────────────────────────────────

        /// <summary>
        /// Performs the actual reset: deletes target files (removing hidden
        /// attributes first) and writes the required registry value.
        /// This method runs on a background thread.
        /// </summary>
        private static void PerformReset()
        {
            // 1. Build the list of target paths using environment variables.
            string programFilesX86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
            string appData         = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            string programData     = Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData);

            var targetPaths = new List<string>
            {
                Path.Combine(programFilesX86, "APi1"),
                Path.Combine(appData, "Avid", "Sibelius", "_manuscript", "HEa3"),
                Path.Combine(programData, "Avid", "Sibelius", "_manuscript", "ACr2"),
                Path.Combine(programData, "Avid", "Sibelius", "_manuscript", "Plugins_v2")
            };

            // 2. Delete each target (file or directory), removing Hidden attribute first.
            foreach (string path in targetPaths)
            {
                DeleteTarget(path);
            }

            // 3. Write registry value:
            //    HKCU\Software\Avid\Sibelius\SibeliusTierSelection
            //        TrialDialogSavedChoice = DWORD 3
            using var key = Registry.CurrentUser.CreateSubKey(
                @"Software\Avid\Sibelius\SibeliusTierSelection",
                writable: true);

            key?.SetValue("TrialDialogSavedChoice", 3, RegistryValueKind.DWord);
        }

        /// <summary>
        /// Removes hidden/system attributes and deletes a file or directory.
        /// Silently skips targets that do not exist.
        /// </summary>
        private static void DeleteTarget(string path)
        {
            try
            {
                if (File.Exists(path))
                {
                    // Remove hidden / system / read-only attributes so deletion succeeds.
                    FileAttributes attrs = File.GetAttributes(path);
                    if ((attrs & (FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly)) != 0)
                    {
                        File.SetAttributes(path,
                            attrs & ~(FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly));
                    }
                    File.Delete(path);
                }
                else if (Directory.Exists(path))
                {
                    RemoveHiddenAttributesRecursive(path);
                    Directory.Delete(path, recursive: true);
                }
            }
            catch (UnauthorizedAccessException)
            {
                // Re-throw with a more descriptive message.
                throw new UnauthorizedAccessException(
                    $"没有权限访问 \"{path}\"。请以管理员身份运行本程序。");
            }
        }

        /// <summary>
        /// Recursively strips <see cref="FileAttributes.Hidden"/>,
        /// <see cref="FileAttributes.System"/>, and <see cref="FileAttributes.ReadOnly"/>
        /// from a directory tree so that it can be deleted.
        /// </summary>
        private static void RemoveHiddenAttributesRecursive(string directoryPath)
        {
            var dirInfo = new DirectoryInfo(directoryPath);
            if (!dirInfo.Exists) return;

            // Fix directory attributes.
            if ((dirInfo.Attributes & (FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly)) != 0)
            {
                dirInfo.Attributes &= ~(FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly);
            }

            // Fix child files.
            foreach (var file in dirInfo.EnumerateFiles("*", SearchOption.AllDirectories))
            {
                if ((file.Attributes & (FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly)) != 0)
                {
                    file.Attributes &= ~(FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly);
                }
            }

            // Fix child directories.
            foreach (var subDir in dirInfo.EnumerateDirectories("*", SearchOption.AllDirectories))
            {
                if ((subDir.Attributes & (FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly)) != 0)
                {
                    subDir.Attributes &= ~(FileAttributes.Hidden | FileAttributes.System | FileAttributes.ReadOnly);
                }
            }
        }

        // ── Status Evaluation ────────────────────────────────────

        /// <summary>
        /// Re-evaluates the current trial status based on <see cref="_lastResetDate"/>
        /// and updates all UI-bound properties accordingly.
        /// </summary>
        private void RefreshStatus()
        {
            if (_lastResetDate is null)
            {
                Status = AppStatus.Unreset;
                RemainingDays = -1;
                RemainingDaysString = "--";
                LastResetDateString = "从未";
                NextExpireDateString = "--";
                return;
            }

            DateTime resetDate = _lastResetDate.Value.Date;
            DateTime expireDate = resetDate.AddDays(TrialDurationDays);
            int daysLeft = (expireDate - DateTime.Today).Days;

            if (daysLeft < 0) daysLeft = 0;

            RemainingDays = daysLeft;
            RemainingDaysString = daysLeft.ToString();
            LastResetDateString = resetDate.ToString("yyyy-MM-dd");
            NextExpireDateString = expireDate.ToString("yyyy-MM-dd");

            Status = daysLeft switch
            {
                0             => AppStatus.Expired,
                <= 3          => AppStatus.ExpiringSoon,
                <= 7          => AppStatus.FewDaysLeft,
                _             => AppStatus.Normal
            };
        }

        // ── Settings Persistence ─────────────────────────────────

        private static string SettingsDirectory =>
            Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "SibeliusReset");

        private static string SettingsFilePath =>
            Path.Combine(SettingsDirectory, "settings.json");

        private void LoadSettings()
        {
            try
            {
                if (!File.Exists(SettingsFilePath))
                    return;

                string json = File.ReadAllText(SettingsFilePath);
                var settings = JsonSerializer.Deserialize<AppSettings>(json);
                _lastResetDate = settings?.LastResetDate;
            }
            catch
            {
                // Corrupted settings — start fresh.
                _lastResetDate = null;
            }
        }

        private void SaveSettings()
        {
            try
            {
                Directory.CreateDirectory(SettingsDirectory);

                var settings = new AppSettings { LastResetDate = _lastResetDate };
                var json = JsonSerializer.Serialize(settings, new JsonSerializerOptions
                {
                    WriteIndented = true
                });
                File.WriteAllText(SettingsFilePath, json);
            }
            catch
            {
                // Non-critical — swallow silently.
            }
        }
    }
}
