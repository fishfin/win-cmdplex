:: Win-CmdPlex - Window Batch Script, Copyright (c) 2020 fishfin

@echo off
setlocal enableDelayedExpansion

:: Generat notes:
:: - 1 and 2 are stdout and stderr streams
:: - 1>null and 2>null redirect the stdout and stderr streams to null, i.e. will not be displayed
:: - 3-9 are undefined
:: - 2>&1 redirects stderr to stdout stream
:: - ^ char in commands before >, & and other symbols is just an escape character
:: - set /a "var=1" simply - the /a flag is for doing basic arithmetic ops, here, assign integer values
::   but can also be used to do +, - etc.
::  - findstr /b ":::" "%~f0" - Here, using findstr, the commands to run are picked up by searching for
::    ":::" that appear at the beginning (/b flag) of the current script; the %0 is the 0th arg, that is,
::    this script name, the ~f flag converts it to full file name path with extension
:: two if statements on the same line mean an "AND" condition

:: Display the output of each process if the /O option is used
:: else ignore the output of each process
:: Note that ^ is just an escape char

set "scriptname=Win-CmdPlex"
set "version=1.0.0-dev"
set "source=https://github.com/fishfin/win-cmdplex"

set "lockHandle=1"
set "cmdsFile=%~1"
set "iterations=%~2"
echo ===============================================================================
echo %scriptname% %version%                    %source%
echo -------------------------------------------------------------------------------
echo Usage: %~n0.bat ^<cmds_file_full_path^> ^<iterations^>
echo ^* iterations=0 for infinite
echo Running %~f0 with options:
echo Commands File: %cmdsFile%
echo Iterations   : %iterations%
echo ===============================================================================

if not defined cmdsFile (
  set "inputnotok=1"
)
if not defined iterations (
  set "inputnotok=1"
)
if defined inputnotok (
  echo Error in parsing input, missing arguments. Please check syntax and try again.
  goto :abort
)

if not exist %cmdsFile% (
  echo Error in parsing input, Commands File %cmdsFile% does not exist
  set "inputnotok=1"
)

set "numcheck=" & for /f "delims=0123456789" %%i in ("%iterations%") do set numcheck=%%i
if defined numcheck (
  echo Error in parsing input, Iterations %iterations% is not an integer
  set "inputnotok=1"
)

if defined inputnotok (
  goto :abort
)

:: Initialize the counters
set /a "cmdCount=0"
for /f "delims=" %%A in (%cmdsFile%) do (
  set /a "cmdCount+=1"
  set /a "runningCmd!cmdCount!=0"
  set cmd!cmdCount!=%%A
)

:: Get a unique base lock name for this particular instantiation.
:: Incorporate a timestamp from WMIC if possible, but don't fail if
:: WMIC not available. Also incorporate a random number.
set "lock="
for /f "skip=1 delims=-+ " %%T in ('2^>nul wmic os get localdatetime') do (
  set "lock=%%T"
  goto :break
)

:break
set "lock=%temp%\lock_%lock%_%random%_"

set /a "nextCmdSeq=0, runningCmdsCount=0, currentIter=0"

:loop
if %iterations% NEQ 0 if !currentIter! GEQ %iterations% if !runningCmdsCount! EQU 0 (
  goto :endLoop
)
  
if !runningCmdsCount! EQU 0 (
  set /a "currentIter+=1"
  echo -------------------------------------------------------------------------------
  echo Starting iteration !currentIter!
  for /l %%N in (1 1 %cmdCount%) do (
    set /a "runningCmdsCount+=1"
    set /a "runningCmd%%N=1"
    echo !time! - cmd%%N: starting !cmd%%N!
    start /b "" cmd /c %lockHandle%^>"%lock%%%N" 2^>^&1 !cmd%%N!
  )
  echo -------------------------------------------------------------------------------
  goto :loop
) else (
  timeout /t 10 /nobreak
  for /l %%N in (1 1 %cmdCount%) do 2>nul (
    if !runningCmd%%N! EQU 1 9>>"%lock%%%N" (
      echo !time! - cmd%%N: finished !cmd%%N!
      set /a "runningCmdsCount-=1"
      set /a "runningCmd%%N=0"
      type "%lock%%%N"
      1>nul 2>nul del "%lock%%%N"
	)
  )
  goto :loop
)

:endLoop
echo Thats all folks^^!

:end
echo ===============================================================================
pause
goto :eof

:abort
echo Run aborted
goto :end