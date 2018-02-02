
@echo off

REM echo Visual C++ product directory could not be found.
rem echo Set nttools to Visual C++ product directory.
rem echo Set LIB and INCLUDE appropriately.
rem set nttools=
rem set LIB=
rem set INCLUDE=

if defined ProgramFiles(x86) (
ECHO "This is a 64-bit OS."
SET "PF=%ProgramFiles(x86)%"
) else (
ECHO "This is a 32-bit OS."
SET "PF=%ProgramFiles%"
) 

for %%f in ("%PF%\Bentley\MicroStation V8i (SELECTseries)\Microstation") do set MS=%%~sf
rem set MS=%PF%\Bentley\MicroStation V8i (SELECTseries)\Microstation
MSMDE=%MS%

set BMAKE_OPT=-I%MS%\mdl\include -I%MS%\jmdl\include
set PATH=;%MS%;%MS%\mdl\bin;%MS%\jmdl\bin;%PATH%
rem set CLASSPATH=.;%MS%\jmdl\lib\rt.jar;%MS%\jmdl\lib\jmdlsdk.jar;%MS%\jmdl\lib\swingall.jar;%MS%\jmdl\lib\bentley.jar;%MS%\jmdl;%CLASSPATH%
set MLINK_STDLIB=%MS%\mdl\library\builtin.dlo %MS%\mdl\library\dgnfileio.dlo %MS%\mdl\library\toolsubs.dlo

rem C:
rem cd \Programme\Bentley\Program\MicroStation\mdl\examples\PLTPNT\


BMAKE -a -dDLM_NO_SIGN +dBUILD_USING_VS2010 PLTPNT.mke


