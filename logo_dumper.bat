:: ����by �ᰲaffggh
@echo off
setlocal enabledelayedexpansion
cd %~dp0
set file_input=%1
set command=%2
set xxd=tools\xxd.exe
set dd=tools\busybox.exe dd
set busybox=tools\busybox.exe
set grep=tools\grep.exe

if "%file_input%"=="" (
call :help
exit /b 0
)
if "%file_input%"=="help" (
call :help
exit /b 0
)
if defined file_input (
if not defined command cls&color 0c&echo   ����δ����ѡ� &echo    �����˳�.... &timeout /t 6 /nobreak>nul&exit /b 1
if /I "%command%"=="extract" call :extract 
if /I "%command%"=="inject" call :inject 
)
exit /b 0
:help
echo     Usage:
echo           logo_dumper.bat ^<logo.img^> ^<extract/inject^>
echo           ^<logo.img^> ���������logo��·��
echo           ^<extract/inject^>
echo                            extract ��logo.img�н���ͼ��
echo                            inject  ��ͼ��ע���logo.img
echo           help  ��ʾ�˰����ļ�
echo            ʾ����
echo                 logo_dumper.bat logo.img extract
echo                 logo_dumper.bat logo.img inject
goto :eof

:extract
for /f "tokens=1 delims=:" %%i in ('!grep! --only-matching --byte-offset --binary --text --perl-regexp "\x{42}\x{4D}" "!file_input!"') do (
set offset=%%i
set /a blockoffset=!offset!+2
for /f %%i in ('!busybox! xxd -p -s !offset! -l 16 !file_input! ^| findstr /b /n "424d................36000000"') do (
for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set "blocksize=!blocksize: =!"
rem echo blocksize=!blocksize!
echo.&echo  BMP:�ļ�ͷƫ�ƣ�!offset!
rem set skipbytes=%%i
rem set /a skipbytes=^(%%i-1^)*16+2
echo.&echo     BMP:��ȡ�������ֽڴ�Сƫ�ƣ�!blockoffset!
rem echo %%j
rem for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo     BMP:��ȡ�������ֽڴ�С��!blocksize!
if not defined n set n=0
set /a n=!n!+1
echo.&echo         ��ͼ��ȡ��ͼƬ!n!.bmp
if "!offset!"=="0" (
!xxd! -p -l !blocksize! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
) else (
!xxd! -p -s !offset! -l !blocksize! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
)
rem !xxd! -p -s !offset! -l !blocksize! !file_input! | !busybox! tr -d "\n" > !n!.bmp.tmp
)
if not defined offset echo.&echo     #δ�ҵ�BMP��ʽ��ͼƬ...
)
goto:eof

:inject
for /f "tokens=1 delims=:" %%i in ('!grep! --only-matching --byte-offset --binary --text --perl-regexp "\x{42}\x{4D}" "!file_input!"') do (
set offset=%%i
set /a blockoffset=!offset!+2
for /f %%i in ('!busybox! xxd -p -s !offset! -l 16 !file_input! ^| findstr /b /n "424d................36000000"') do (
for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set "blocksize=!blocksize: =!"
rem echo blocksize=!blocksize!
if not defined n (
echo.&echo     ��ȡ�����ļ�ͷ...
!dd! if=!file_input! of=newlogo.img bs=1 count=!offset! 1>nul 2>nul
)

rem ���ͼ���С
if not defined n set n=1

if exist "!n!.bmp" (
for %%a in ("!n!.bmp") do set "bmp_size=%%~za"
for %%b in ("newlogo.img") do set "newlogo_size=%%~zb"
rem ������հ�����
set /a "empty_size=!offset!-!newlogo_size!"
)


echo.&echo  BMP:�ļ�ͷƫ�ƣ�!offset!
rem set skipbytes=%%i
echo.&echo     BMP:��ȡ�������ֽڴ�Сƫ�ƣ�!blockoffset!
rem echo %%j
rem for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo     BMP:��ȡ�������ֽڴ�С��!blocksize!
echo.&echo         ��ͼע���ͼƬ!n!.bmp
if not "!empty_size!"=="0" (
echo.&echo     BMP:��⵽ǰ�����!empty_size!�ֽڵĿռ䣬���ڴ�Դ�ļ����...
!dd! if=!file_input! bs=1 skip=!newlogo_size! count=!empty_size! >> newlogo.img
rem del /s /q empty.tmp > nul
)
echo.&echo     BMP:���ͼ���Ƿ�ΪBMP��ʽ...
for /f %%i in ('!xxd! -p -l 2 !n!.bmp') do (
if not "%%i"=="424d" echo.&echo     #����!n!.bmp����ͼƬ������BMP��ʽ��&pause&exit /b 1
if not "!blocksize!"=="!bmp_size!" echo.&echo     #���棡!n!.bmp����ͼƬ��С��Դ����Ĳ����������޷���ʾ��&echo.echo     #�ű�Ĭ�Ϻ����������...&timeout /t 3 /nobreak >nul
)
!busybox! cat "!n!.bmp" >> newlogo.img
set /a n=n+1
for %%i in ("!file_input!") do set original_size=%%~zi
for %%b in ("newlogo.img") do set newlogo_size=%%~zb
set /a footpad_size=!original_size!-!newlogo_size!
)
echo.&echo     #�Զ���⾵���С�Ƿ����...
for %%b in ("newlogo.img") do set "newlogo_size=%%~zb"
for %%b in ("!file_input!") do set "original_size=%%~zb"
)
if not "!newlogo_size!"=="!original_size!" ( 
echo.&echo     #���棡�ļ���С����ȣ����ڴ�Դ�ļ�����ȡ���...
if not exist "!n!.bmp" (
echo.&echo     BMP:��⵽����!footpad_size!��С���ֽ���Դ���񲻷�
echo.&echo     BMP:�Զ����....
!xxd! -p -s !newlogo_size! -l !footpad_size! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r >> newlogo.img
)
) else (
echo     #�ļ���С���...
)
goto:eof
