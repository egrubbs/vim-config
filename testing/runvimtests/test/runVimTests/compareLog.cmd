@echo off %debug%
::/*************************************************************************/^--*
::**
::* FILE: 	compareLog.cmd
::* PRODUCT:	runVimTests
::* AUTHOR: 	Ingo Karkat <ingo@karkat.de>
::* DATE CREATED:   11-Feb-2009
::*
::*******************************************************************************
::* CONTENTS: 
::  Runs a runVimTests self-test and compares the test output with previously
::  captured nominal output. 
::  The command-line arguments to runVimTests and the test file are embedded in
::  the captured output filename and are extracted automatically: 
::  testrun.suite-1-v.log ->
::	$ runVimTests -1 -v testrun.suite > /tmp/testrun.suite-1-v.log 2>&1
::  The special name "testdir" represents all tests in the directory (i.e. '.'): 
::  testdir-1-v.log ->
::	$ runVimTests -1 -v . > /tmp/testdir-1-v.log 2>&1
::       	
::* REMARKS: 
::       	
::* DEPENDENCIES:
::  - GNU sed, diff available through %PATH% or 'unix.cmd' script. 
::
::* REVISION	DATE		REMARKS 
::	005	28-May-2009	Pin down locale to get reproducible sorting order. 
::	004	12-Mar-2009	Also capturing stderr output, e.g. for "test not
::				found" errors. 
::				ENH: Fixing Windows differences in the VIM
::				invocation by making substitutions in the
::				captured log. 
::	003	07-Mar-2009	The test file (suite) is now also embedded in
::				the captured output name so that multiple test
::				files and suites can be captured. 
::	002	25-Feb-2009	Command-line arguments are now embedded in the
::				captured output filename and extracted
::				automatically. 
::	001	11-Feb-2009	file creation
::*******************************************************************************
setlocal enableextensions

:: Pin down locale to get reproducible sorting order. 
set LC_ALL=C

call unix --quiet >NUL 2>&1

if "%~1" == "" (set old=testdir.log) else (set old=%~1)
if "%~1" == "" (set log=%TEMP%\testdir.log) else (set log=%TEMP%\%~nx1)
if exist "%log%" del "%log%" || exit /B 1

if not exist "%old%" (
    echo.ERROR: Old log "%old%" does not exist!
    exit /B 1
)

set options=
set tests=testdir
if "%~1" == "" (goto:run)
set tests=
set options=%~n1

:cutOffTests
if "%options%" == "" (goto:run)
set tests=%tests%%options:~0,1%
set options=%options:~1%
if "%options%" == "" (goto:run)
if not "%options:~0,1%" == "-" (goto:cutOffTests)

set options=%options:--= !!%
set options=%options:-= !%
set options=%options:!=-%

:run
if "%tests%" == "testdir" set tests=.
call runVimTests.cmd%options% "%tests%" > "%log%" 2>&1

:fixWindowsDifferencesInLog
:: There are a couple of differences in the VIM invocation between Windows and
:: Linux. To avoid that these always show up in the diff, we perform some
:: substitutions in the line that logs the VIM invocation to make the captured
:: Windows log look like the old log.(Which I always create on Unix, because the
:: Windows diff is able to handle files with different line endings
:: transparently.) 
:: - On Windows, I use a custom 'runVimTestsSetup.vim' global setup script, but
::   on Unix, I don't. (This is just for me.)
:: - In the Windows shell, all VIM arguments must be enclosed in double quotes,
::   but the Unix shell script uses single quotes where possible. 
sed -i -e "/^Starting test run/{n;s/ -S \d034[^\d034]*runVimTestsSetup.vim\d034//;s/ \d034\([^'\d034]*\)\d034/ '\1'/g}" "%log%"

:showDifferences
echo.
echo.DIFFERENCES:
diff -u "%old%" "%log%"

endlocal
