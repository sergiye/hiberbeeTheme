@echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -prerelease -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) DO (
SET msbuild="%%F"
)
ECHO %msbuild%

@%msbuild% HiberbeeTheme.sln /t:restore /p:RestorePackagesConfig=true
@%msbuild% HiberbeeTheme.sln /t:Rebuild /p:DebugType=None /p:Configuration=Release /p:Platform="Any CPU"

if errorlevel 1 goto error

goto exit
:error
pause
:exit
