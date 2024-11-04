@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

:: Запрос имени пользователя
set /p username="Введите ваше имя пользователя: "

:: Установка фиксированного пути для установки Prism Launcher
set "PrismPath=%AppData%\PrismLauncher"
set "PrismExePath=%LocalAppData%\Programs\PrismLauncher\prismlauncher.exe"

:: Создание временной директории для скачивания
mkdir "%TEMP%\prism_downloads"
cd /d "%TEMP%\prism_downloads"

:: Проверка curl
where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo Не найден curl. Установите его или используйте альтернативный метод загрузки.
    pause
    exit /b 1
)

:: Создание файла accounts.json для автоматического входа с введенным именем пользователя
echo Создание файла accounts.json...
if not exist "%PrismPath%" mkdir "%PrismPath%"
(
echo {"accounts":[{"entitlement":{"canPlayMinecraft":true,"ownsMinecraft":true},"msa-client-id":"","type":"MSA"},{"active":true,"entitlement":{"canPlayMinecraft":true,"ownsMinecraft":true},"profile":{"capes":[],"id":"1d759f9c422b34829ab32a40f2a083d3","name":"%username%","skin":{"id":"","url":"","variant":""}},"type":"Offline","ygg":{"extra":{"clientToken":"bf611e6cb4204f36ab913b577d222b95","userName":"%username%"},"iat":1729204961,"token":"0"}}],"formatVersion":3}
) > "%PrismPath%\accounts.json"

:: Проверка наличия установленной Java
java -version >nul 2>&1
if %errorlevel% equ 0 (
    echo Java уже установлена.
    set "InstallJava=N"
) else (
    set /p InstallJava="Java не обнаружена. Хотите установить JDK Axiom? (Д/Н): "
)

set "JDKPath=%ProgramFiles%\Axiom\AxiomJDK-Pro-17\bin\javaw.exe"
if not exist "%JDKPath%" (
    if /i "%InstallJava%"=="Д" (
        :: Загрузка JDK Axiom
        echo Загрузка JDK Axiom...
        curl -L -o axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi "https://download.axiomjdk.ru/axiomjdk-pro/17.0.13+12/axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi"

        :: Установка JDK Axiom в директорию по умолчанию
        echo Установка JDK Axiom...
        msiexec.exe /i "axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi" /norestart

        :: Проверка установки JDK Axiom
        if exist "%ProgramFiles%\Axiom\AxiomJDK-Pro-17\bin\javaw.exe" (
            set "JavaPath=%ProgramFiles%\Axiom\AxiomJDK-Pro-17\bin\javaw.exe"
            echo JDK Axiom успешно установлен.
        ) else (
            echo Ошибка: Установка JDK Axiom не удалась.
            pause
            exit /b 1
        )
    )
) else (
    echo JDK Axiom уже установлен в системе.
)

:: Проверка Prism Launcher
if not exist "%PrismExePath%" (
    echo Prism Launcher не установлен. Начало установки...

    :: Загрузка Prism Launcher
    if not exist "PrismLauncher-Windows-MSVC-Setup-9.1.exe" (
        echo Загрузка Prism Launcher...
        curl -L -o PrismLauncher-Windows-MSVC-Setup-9.1.exe ^
            "https://github.com/PrismLauncher/PrismLauncher/releases/download/9.1/PrismLauncher-Windows-MSVC-Setup-9.1.exe"
    )

    :: Установка Prism Launcher в тихом режиме без автозапуска
    echo Установка Prism Launcher...
    start /wait PrismLauncher-Windows-MSVC-Setup-9.1.exe /SILENT /DIR="%LocalAppData%\Programs\PrismLauncher"
    if %errorlevel% neq 0 (
        echo Ошибка при установке Prism Launcher. Код ошибки: %errorlevel%
        pause
        exit /b 1
    )
) else (
    echo Prism Launcher уже установлен в системе.
)

echo Установка завершена! Вы можете запустить Prism Launcher вручную.
pause
