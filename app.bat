@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 1. Leitura de parâmetros
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

:: 2. Verificação de dependência: cloudflared
where cloudflared >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Cloudflared nao encontrado no PATH.
    echo Por favor, instale o Cloudflared antes de executar este script.
    pause
    exit /b 1
)

:: 3. Criação dos processos RDP e do túnel
for /f "skip=1 tokens=2 delims== " %%I in ('
    wmic process call create "cloudflared access rdp --hostname ""%hostname%"" --url rdp://localhost:%port%" ^| findstr /i "ProcessId"
') do set "CloudflaredPID=%%I"

for /f "skip=1 tokens=2 delims== " %%I in ('
    wmic process call create "mstsc /v:localhost:%port%" ^| findstr /i "ProcessId"
') do set "MstscPID=%%I"

:monitor_loop
timeout /t 2 >nul

:: Se o túnel cair, fecha o Remote Desktop
tasklist /FI "PID eq %CloudflaredPID%" /NH | findstr /i "cloudflared.exe" >nul
if errorlevel 1 (
    taskkill /PID %MstscPID% /F >nul 2>&1
    goto finish
)

:: Se o cliente RDP fechar, encerra o túnel
tasklist /FI "PID eq %MstscPID%" /NH | findstr /i "mstsc.exe" >nul
if errorlevel 1 (
    taskkill /PID %CloudflaredPID% /F >nul 2>&1
    goto finish
)

goto monitor_loop

:finish
endlocal
exit /b