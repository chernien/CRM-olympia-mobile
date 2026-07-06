@echo off
REM ============================================================
REM  OLYMPIA - Tunnel USB (adb reverse) + verification backend
REM  Double-cliquer apres avoir branche le telephone.
REM  Redirige localhost:5000 (telephone) -> localhost:5063 (PC)
REM ============================================================
setlocal
chcp 65001 >nul
title OLYMPIA - Tunnel USB

REM --- Trouver adb : PATH d'abord, sinon SDK Android par defaut ---
set "ADB=adb"
where adb >nul 2>nul
if errorlevel 1 (
  set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
)

echo.
echo === Telephone(s) connecte(s) ===
"%ADB%" devices

REM --- Verifier qu'au moins un appareil est en mode "device" ---
set "DEVICE_OK="
for /f "skip=1 tokens=1,2" %%A in ('"%ADB%" devices') do (
  if "%%B"=="device" set "DEVICE_OK=1"
)
if not defined DEVICE_OK (
  echo.
  echo [ERREUR] Aucun telephone detecte en mode "device".
  echo   - Verifie le cable USB
  echo   - Active le "Debogage USB" dans les options developpeur
  echo   - Autorise l'ordinateur sur le telephone si demande
  echo.
  pause
  exit /b 1
)

echo.
echo === Mise en place du tunnel (5000 -^> 5063) ===
"%ADB%" reverse tcp:5000 tcp:5063
if errorlevel 1 (
  echo [ERREUR] Impossible de creer le tunnel adb reverse.
  pause
  exit /b 1
)
echo Tunnel OK.

echo.
echo === Tunnels actifs ===
"%ADB%" reverse --list

echo.
echo === Test du backend (PC:5063) ===
for /f %%C in ('curl -s -m 6 -o nul -w "%%{http_code}" -X POST http://localhost:5063/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"ping\",\"password\":\"ping\"}"') do set "CODE=%%C"

if "%CODE%"=="000" (
  echo [ATTENTION] Le backend ne repond pas sur le port 5063.
  echo   Lance d'abord le backend .NET ^(dotnet run --launch-profile https^).
) else (
  echo Backend joignable ^(HTTP %CODE%^).  ^(400/401 = normal ici, le serveur repond bien^)
)

echo.
echo ============================================================
echo  Termine. Tu peux utiliser l'app sur le telephone.
echo  Relance ce script a chaque fois que tu rebranches le cable.
echo ============================================================
echo.
pause
endlocal
