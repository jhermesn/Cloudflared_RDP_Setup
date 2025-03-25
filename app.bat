@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

if "%~1"=="" (
    set /p hostname="Digite o hostname para a conexão RDP (pressione Enter para usar o padrão 'IP.DA.MAQUINA'): "
    if "%hostname%"=="" set hostname=IP.DA.MAQUINA
) else (
    set hostname=%~1
) 

if "%~2"=="" (
    set /p port="Digite a porta que você deseja escutar (Padrão: 3390): "
    if "%port%"=="" set port=3390
) else (
    set port=%~2
)

where cloudflared >nul 2>&1
if errorlevel 1 (
    if "%~3"=="" (
        set /p version="Digite a versao do Cloudflared a ser instalada (Padrão: 'latest' para a ultima versao): "
        if "%version%"=="" set version=latest
    ) else (
        set version=%~3
    )
    if /I "%version%"=="latest" (
        set "downloadURL=https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi"
    ) else (
        set "downloadURL=https://github.com/cloudflare/cloudflared/releases/download/%version%/cloudflared-windows-amd64.msi"
    )
    bitsadmin /transfer cloudflaredDownloadJob /download /priority normal "%downloadURL%" "%TEMP%\cloudflared.msi" >nul 2>&1
    if errorlevel 1 (
         echo [ERRO] Falha ao baixar o Cloudflared.
         pause
         exit /b 1
    )
    start /wait msiexec /i "%TEMP%\cloudflared.msi" /qn
    if errorlevel 1 (
         echo [ERRO] Falha ao instalar o Cloudflared.
         pause
         exit /b 1
    )
    where cloudflared >nul 2>&1
    if errorlevel 1 (
         echo Cloudflared nao foi encontrado apos a instalacao.
         pause
         exit /b 1
    )
)

for /f "tokens=2 delims==; " %%I in ('wmic process call create "cloudflared access rdp --hostname %hostname% --url rdp://localhost:%port%" ^| find "ProcessId"') do set CloudflaredPID=%%I
for /f "tokens=2 delims==; " %%I in ('wmic process call create "mstsc /v:localhost:%port%" ^| find "ProcessId"') do set MstscPID=%%I

:monitor_loop
timeout /t 2 >nul
tasklist /fi "pid eq %CloudflaredPID%" | findstr /i "cloudflared.exe" >nul
if errorlevel 1 (
    taskkill /pid %MstscPID% /f >nul 2>&1
    goto finish
)
tasklist /fi "pid eq %MstscPID%" | findstr /i "mstsc.exe" >nul
if errorlevel 1 (
    taskkill /pid %CloudflaredPID% /f >nul 2>&1
    goto finish
)
goto monitor_loop

:finish
exit /b
