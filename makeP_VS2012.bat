
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

rem for %%f in ("%PF%\Bentley\MicroStation V8i (SELECTseries)\Microstation") do set MS=%%~sf\
rem set MS=%PF%\Bentley\MicroStation V8i (SELECTseries)\Microstation
set MSMDE=%MS%


set BMAKE_OPT=-I%MS%\mdl\include -I%MS%\jmdl\include
set PATH=;%MS%;%MS%\mdl\bin;%MS%\jmdl\bin;%PATH%
set CLASSPATH=.;%MS%\jmdl\lib\rt.jar;%MS%\jmdl\lib\jmdlsdk.jar;%MS%\jmdl\lib\swingall.jar;%MS%\jmdl\lib\bentley.jar;%MS%\jmdl;%CLASSPATH%
rem set MLINK_STDLIB=%MS%\mdl\library\builtin.dlo %MS%\mdl\library\dgnfileio.dlo %MS%\mdl\library\toolsubs.dlo

rem C:
rem cd \Programme\Bentley\Program\MicroStation\mdl\examples\PLTPNT\

rem set PolicyFileMapMki=$(MSMDE)/mdl/include/MdlSdkPolicyFileNames.mki
rem set PolicyFileNamesMki=$(MSMDE)/mdl/include/MdlSdkPolicyFileNames.mki

rem -dDLM_NO_NTBSADDR

BMAKE -a -dDLM_NO_SIGN +dBUILD_USING_VS2012 PLTPNT.mke


