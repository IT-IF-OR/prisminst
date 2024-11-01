@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

:: Запрос имени пользователя
set /p username="Введите ваше имя пользователя: "

:: Установка путей
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

:: Создание accounts.json
if not exist "%PrismPath%\accounts.json" (
    echo Создание файла accounts.json...
    mkdir "%PrismPath%"
    (
    echo {"accounts":[{"entitlement":{"canPlayMinecraft":true,"ownsMinecraft":true},"msa-client-id":"","type":"MSA"},{"active":true,"entitlement":{"canPlayMinecraft":true,"ownsMinecraft":true},"profile":{"capes":[],"id":"1d759f9c422b34829ab32a40f2a083d3","name":"%username%","skin":{"id":"","url":"","variant":""}},"type":"Offline","ygg":{"extra":{"clientToken":"bf611e6cb4204f36ab913b577d222b95","userName":"%username%"},"iat":1729204961,"token":"0"}}],"formatVersion":3}
    ) > "%PrismPath%\accounts.json"
    echo Файл создан успешно.
) else (
    echo Файл accounts.json уже существует. Продолжение установки...
)

:: Проверка JDK Axiom
set "JDKPath=%ProgramFiles%\Axiom\AxiomJDK-Pro-17\bin\javaw.exe"
if not exist "%JDKPath%" (
    echo JDK Axiom не установлен. Начало установки...

    :: Загрузка JDK Axiom
    if not exist "axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi" (
        echo Загрузка JDK Axiom...
        curl -L -o axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi ^
            "https://download.axiomjdk.ru/axiomjdk-pro/17.0.13+12/axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi"
    )

    :: Установка JDK Axiom
    echo Установка JDK Axiom...
    msiexec.exe /i "axiomjdk-jdk-pro17.0.13+12-windows-amd64.msi" /norestart > nul 2>&1
    if %errorlevel% neq 0 (
        echo Ошибка при установке JDK Axiom. Код ошибки: %errorlevel%
        pause
        exit /b 1
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

    :: Установка Prism Launcher
    echo Установка Prism Launcher...
    start /wait /min PrismLauncher-Windows-MSVC-Setup-9.1.exe /SILENT /DIR="%LocalAppData%\Programs\PrismLauncher"
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