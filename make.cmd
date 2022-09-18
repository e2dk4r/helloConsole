@echo off

REM ----------------------------------------------------------------
REM ENTRY POINT
REM ----------------------------------------------------------------

REM prepare environment
call :set

set "NOARG=0"

if "%1" equ "" (
  set "NOARG=1"
)

if "%NOARG%" equ "1" ( REM if no argument given, call all functions
  call :all
) else ( REM call other arguments
:loop
  REM break out of loop if there no other argument left
  if "%1" equ "" (
    goto :loop_finish
  )

  REM call argument rule
  call :%1

  REM shift arguments so %2 becomes %1
  shift

  REM check loop
  goto :loop
)
:loop_finish

REM reset environment
set "NOARG="
call :unset

REM exit with success
exit /b 0

REM ----------------------------------------------------------------
REM FUNCTIONS
REM ----------------------------------------------------------------

REM all(void) void
REM all executes default rules
:all
  call :%PROJECT%
  goto :EOF

REM helloConsole(void) void
REM helloConsole builds helloConsole executable
REM
REM dependent rules
REM   - info
REM   - dirs
:helloConsole
  call :info
  call :dirs

  REM for vs c compiler (cl.exe)
  echo cl -O2 -Fe%OUTPUT% -Fo%OUTPUT%.obj %CFLAGS% %SOURCES% /link %LDFLAGS% %LIBS%
  cl -O2 -Fe%OUTPUT% -Fo%OUTPUT%.obj %CFLAGS% %SOURCES% /link %LDFLAGS% %LIBS%

  REM for clang compiler
  REM echo clang %CFLAGS% -o %OUTPUT% %SOURCES% %LDFLAGS% %LIBS%
  REM clang %CFLAGS% -o %OUTPUT% %SOURCES% %LDFLAGS% %LIBS%
  goto :EOF

REM clean(void) void
REM clean cleans executables and object files
:clean
  del /q /f %OUTPUT% %OUTPUT%.obj %BUILD_DIR%\%PROJECT%.pdb
  @echo Cleaned executables and object files
  goto :EOF

REM info(void) void
REM info show information about current
:info
  @echo ################################################################
  @echo   Arch:      %ARCH%
  @echo   Cpu:       %CPU%
  @echo   WinVer:    %WINVER%
  @echo   Timestamp: %TIMESTAMP%
  @echo   CFLAGS:    %CFLAGS%
  @echo   LDFLAGS:   %LDFLAGS%
  @echo   LIBS:      %LIBS%
  @echo   Output:    %OUTPUT%
  @echo ################################################################
  goto :EOF

REM dirs() void
REM dirs creates directories
:dirs
  mkdir %BUILD_DIR% > nul 2>&1
  goto :EOF

REM set(void) void
REM set inserts environment variables
:set
  REM NOTE: REM make sure variables has no spaces, because of argument passing.
  REM sometimes `cmd.exe` confuses itself

  set "PROJECT=helloConsole"
  set "VERSION=v0.0.1"

  REM for vs c compiler
  REM ref:
  REM   - https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-alphabetically
  REM   - https://docs.microsoft.com/en-us/cpp/build/reference/linker-options
  set "CFLAGS=/nologo /W3 /Z7 /GS- /Gs999999 /DUNICODE /D_UNICODE"
  set "LDFLAGS=/incremental:no /opt:icf /opt:ref /subsystem:console"
  
  REM for clang compiler
  REM set "CFLAGS=-g -gdwarf-2 -nostdlib -nostdlib++ -mno-stack-arg-probe -maes"
  REM set "LDFLAGS=-fuse-ld=lld -Wl,-subsystem:console"
  set "LIBS="

  set "BUILD_DIR=build"
  set "SOURCES=src\main.cpp"
  set "OUTPUT=%BUILD_DIR%\%PROJECT%.exe"

  REM Format  
  REM   yyyy - using a 4-digit year
  REM   MM   - 2-digit month
  REM   dd   - 2-digit day
  REM   HH   - 2-digit hour
  REM   mm   - 2-digit minute
  REM   ss   - 2-digit second
  REM   ffff - 4-digit millisecond.
  REM   zzzz - UTC indicator
  REM Example:
  REM   yyyyMMddTHHmmssffffzz         -> 20190627T1540500718+03
  REM   yyyy-MM-dd HH:mm:ss.ffff zzzz -> 2019-06-27 15:40:50.0718 +03:00
  REM
  REM Referance:
  REM   - https://ss64.com/nt/syntax-getdate.html
  REM   - https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Get-Date
  REM Bugs:
  REM   Some version of powershell does not respect `zz` modifier if you converted your time to UTC.
  REM   `zz` shows your current time even if time is converted to UTC.
  REM   so I used `+00` to indicate it is UTC
  for /f "usebackq delims=" %%i in (`powershell -NoLogo -NoProfile -Command "$now = Get-Date; $now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.ffff+00')"`) do @set "TIMESTAMP=%%i"

  REM get architecture
  for /f "usebackq delims=" %%i in (`powershell -NoLogo -NoProfile -Command "$arch = If ([Environment]::Is64BitOperatingSystem) { 'amd64' } Else { 'x86' }; $arch"`) do @set "ARCH=%%i"
  REM get cpu
  for /f "usebackq delims=" %%i in (`powershell -NoLogo -NoProfile -Command "$cpu = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0\' ProcessorNameString).ProcessorNameString.Trim(); $threads = [Environment]::ProcessorCount; [String]::Format('{0} {1} threads', $cpu, $threads)"`) do @set "CPU=%%i"
  REM get windows version like winver.exe
  for /f "usebackq delims=" %%i in (`powershell -NoLogo -NoProfile -Command "$current = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion'; [String]::Format('Windows {0}.{1} Build {2}.{3}', $current.CurrentMajorVersionNumber, $current.CurrentMinorVersionNumber, $current.CurrentBuild, $current.UBR)"`) do @set "WINVER=%%i"

  REM add build variables
  REM NOTE: no spaces allowed or compiler confuses

  REM for vs c compiler (cl.exe)
  set "CFLAGS=%CFLAGS% /DAPP_VERSION#\"%VERSION%\""
  set "CFLAGS=%CFLAGS% /DAPP_BUILD_TIMESTAMP#\"%TIMESTAMP%\""

  REM for clang compiler
  REM set "CFLAGS=%CFLAGS% -DAPP_VERSION=\"%VERSION%\""
  REM set "CFLAGS=%CFLAGS% -DAPP_BUILD_TIMESTAMP=\"%TIMESTAMP%\""
  goto :EOF

REM unset(void) void
REM unset removes environment variables
:unset
  set "PROJECT="
  set "VERSION="

  set "CFLAGS="
  set "LDFLAGS="
  set "LIBS="

  set "BUILD_DIR="
  set "SOURCES="
  set "OUTPUT="

  set "TIMESTAMP="
  set "ARCH="
  set "CPU="
  set "WINVER="
  goto :EOF
