
@echo off

REM echo Visual C++ product directory could not be found.
rem echo Set nttools to Visual C++ product directory.
rem echo Set LIB and INCLUDE appropriately.
rem set nttools=
rem set LIB=
rem set INCLUDE=

rem for %%f in ("%ProgramFiles%\Bentley\MicroStation CONNECT Edition Update 3\MicroStation") do set MS_CE=%%~sf
rem set MS_CE=%PF%\Bentley\MicroStation V8i (SELECTseries)\Microstation
rem MS=%MS_CE%
rem set MSMDE=%MS_CE%

set BMAKE_OPT=-I%MS%\mdl\include -I%MS%\jmdl\include
set PATH=;%MS%;%MS%\mdl\bin;%MS%\jmdl\bin;%PATH%

rem set MLINK_STDLIB=%MS%\mdl\library\builtin.dlo %MS%\mdl\library\dgnfileio.dlo %MS%\mdl\library\toolsubs.dlo

rem C:
rem cd \Programme\Bentley\Program\MicroStation\mdl\examples\PLTPNT\

rem set PolicyFileMapMki=$(MSMDE)mdl/include/MdlSdkPolicyFileNames.mki
rem set PolicyFileNamesMki=$(MSMDE)mdl/include/MdlSdkPolicyFileNames.mki

BMAKE -a -dDLM_NO_SIGN +dBUILD_USING_VS2012 PLTPNT.mke


