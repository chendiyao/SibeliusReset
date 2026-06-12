# Sibelius重置 - Windows 版

Sibelius 试用期重置工具的 Windows 版本，使用 .NET 8 WPF 开发，从 macOS SwiftUI 版本移植而来。

## 环境要求

- **操作系统**: Windows 10 / 11 (x64)
- **.NET 8 SDK**: 需要安装 [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) 用于编译构建

## 项目结构

```
Windows/
├── SibeliusReset.sln          # 解决方案文件
├── build.bat                   # 一键构建脚本
├── README.md                   # 本文件
└── SibeliusReset/
    ├── SibeliusReset.csproj    # 项目文件
    ├── App.xaml                # 应用程序入口 (XAML)
    ├── App.xaml.cs             # 应用程序入口 (代码)
    ├── app.manifest            # UAC 管理员权限清单
    └── Assets/
        └── AppIcon.ico         # 应用程序图标 (需自行生成)
```

## 构建方法

### 使用构建脚本（推荐）

双击运行 `build.bat`，脚本会自动检查环境并构建项目。构建产物位于 `build/publish/` 目录。

### 手动构建

```bash
dotnet publish SibeliusReset/SibeliusReset.csproj -c Release -o build/publish
```

## 关于图标

项目需要一个 `Assets/AppIcon.ico` 图标文件。请将 macOS 版的 `AppLogo.png` 转换为 `.ico` 格式：

1. 使用在线工具（如 [ConvertICO](https://convertico.com/)）将 `AppLogo.png` 转换为 `AppIcon.ico`
2. 将生成的 `AppIcon.ico` 放入 `SibeliusReset/Assets/` 目录

> **注意**: 未放置图标文件时构建可能会产生警告，但不影响编译。

## 使用说明

1. 运行构建后的 `Sibelius重置.exe`
2. 程序启动时会请求 **管理员权限**（UAC 弹窗），请点击「是」
3. 管理员权限是必需的，因为重置操作需要修改注册表和系统级文件

> **重要**: 本程序需要以管理员身份运行。如果拒绝 UAC 提权请求，程序将无法启动。
