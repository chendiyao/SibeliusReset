@echo off
chcp 65001 >nul 2>&1
setlocal

echo.
echo  ╔═══════════════════════════════════════════╗
echo  ║     Sibelius重置 - Windows 构建脚本       ║
echo  ╚═══════════════════════════════════════════╝
echo.

:: ── 检查 dotnet SDK ──────────────────────────────
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo  [错误] 未找到 .NET SDK！
    echo.
    echo  请先安装 .NET 8 SDK:
    echo  https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    echo  安装完成后重新运行本脚本。
    pause
    exit /b 1
)

echo  [✓] 检测到 .NET SDK:
for /f "tokens=*" %%v in ('dotnet --version') do echo      版本: %%v
echo.

:: ── 设置路径 ─────────────────────────────────────
set "SCRIPT_DIR=%~dp0"
set "PROJECT=%SCRIPT_DIR%SibeliusReset\SibeliusReset.csproj"
set "PUBLISH_DIR=%SCRIPT_DIR%build\publish"
set "EXE_NAME=Sibelius重置.exe"

:: ── 清理 ─────────────────────────────────────────
if exist "%PUBLISH_DIR%" (
    echo  [1/3] 清理旧构建...
    rmdir /s /q "%PUBLISH_DIR%" >nul 2>&1
) else (
    echo  [1/3] 无需清理
)

:: ── 还原依赖 ─────────────────────────────────────
echo  [2/3] 还原 NuGet 依赖...
dotnet restore "%PROJECT%" --verbosity quiet
if %errorlevel% neq 0 (
    echo.
    echo  [错误] 依赖还原失败！
    pause
    exit /b 1
)

:: ── 发布 ─────────────────────────────────────────
echo  [3/3] 编译并打包为单文件 EXE...
echo.
dotnet publish "%PROJECT%" ^
    -c Release ^
    -r win-x64 ^
    --self-contained true ^
    -p:PublishSingleFile=true ^
    -p:IncludeNativeLibrariesForSelfExtract=true ^
    -p:DebugType=none ^
    -p:DebugSymbols=false ^
    -o "%PUBLISH_DIR%"

if %errorlevel% neq 0 (
    echo.
    echo  [错误] 编译失败！请检查上方的错误信息。
    echo  常见原因: 缺少 .NET 8 Desktop Runtime 工作负载
    echo  修复命令: dotnet workload install desktop
    pause
    exit /b 1
)

:: ── 完成 ─────────────────────────────────────────
echo.
echo  ╔═══════════════════════════════════════════╗
echo  ║            构建成功！                     ║
echo  ╚═══════════════════════════════════════════╝
echo.
echo  输出文件: %PUBLISH_DIR%\%EXE_NAME%
echo.
echo  注意: 运行时需要管理员权限（会自动弹出 UAC 提示）
echo.

:: 询问是否直接打开输出目录
set /p OPEN_DIR="  是否打开输出目录？(Y/N): "
if /i "%OPEN_DIR%"=="Y" (
    explorer "%PUBLISH_DIR%"
)

endlocal
