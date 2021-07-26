:: 作者by 酷安affggh
@echo off
setlocal enabledelayedexpansion
cd %~dp0
set file_input=%1
set command=%2
set xxd=tools\xxd.exe
set dd=tools\busybox.exe dd
set busybox=tools\busybox.exe
if "%file_input%"=="" (
echo     Usage:
echo           logo_dumper.bat ^<logo.img^> ^<extract/inject^>
echo           ^<logo.img^> 这里是你的logo的路径
echo           ^<extract/inject^>
echo                            extract 从logo.img中解析图像
echo                            inject  将图像注入回logo.img
echo           help  显示此帮助文件
echo            示例：
echo                 logo_dumper.bat logo.img extract
echo                 logo_dumper.bat logo.img inject
)
if "%file_input%"=="help" (
echo     Usage:
echo           logo_dumper.bat ^<logo.img^> ^<extract/inject^>
echo           ^<logo.img^> 这里是你的logo的路径
echo           ^<extract/inject^>
echo                            extract 从logo.img中解析图像
echo                            inject  将图像注入回logo.img
echo           help  显示此帮助文件
echo            示例：
echo                 logo_dumper.bat logo.img extract
echo                 logo_dumper.bat logo.img inject
)
if defined file_input (
if not defined command cls&color 0c&echo   错误，未定义选项。 &echo    正在退出.... &timeout /t 6 /nobreak>nul&exit /b 1
if /I "%command%"=="extract" call :extract 
if /I "%command%"=="inject" call :inject 
)
exit /b 0
:extract
for /f "tokens=1,2 delims=:" %%i in ('!xxd! -c 16 -p !file_input! ^| findstr /b /n 424d................36') do (
set /a offset=(^%%i-1^)*16
echo.&echo  BMP:文件头偏移：!offset!
rem set skipbytes=%%i
set /a skipbytes=^(%%i-1^)*16+2
echo.&echo     BMP:读取的数据字节大小偏移：!skipbytes!
rem echo %%j
for /f %%i in ('!busybox! od -td -An --skip-bytes=!skipbytes! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo     BMP:读取的数据字节大小：!blocksize!
set /a n=n+1
echo.&echo         试图截取该图片!n!.bmp
!xxd! -p -s !offset! -l !blocksize! logo.img | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
)
goto:eof

:inject
for /f "tokens=1,2 delims=:" %%i in ('!xxd! -c 16 -p !file_input! ^| findstr /b /n 424d................36') do (

set /a offset=(^%%i-1^)*16
if not defined n (
echo.&echo     截取镜像文件头...
!dd! if=!file_input! of=newlogo.img bs=1 count=!offset! 1>nul
)

rem 检测图像大小
if not defined n set n=1

if exist "!n!.bmp" (
for %%a in ("!n!.bmp") do set bmp_size=%%~za
for %%b in ("newlogo.img") do set newlogo_size=%%~zb
rem 加入检测空白区域
set /a empty_size=!offset!-!newlogo_size!
)


echo.&echo  BMP:文件头偏移：!offset!
rem set skipbytes=%%i
set /a skipbytes=^(%%i-1^)*16+2
echo.&echo     BMP:读取的数据字节大小偏移：!skipbytes!
rem echo %%j
for /f %%i in ('!busybox! od -td -An --skip-bytes=!skipbytes! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo     BMP:读取的数据字节大小：!blocksize!

echo.&echo         试图注入该图片!n!.bmp
if not "!empty_size!"=="0" (
echo.&echo     BMP:检测到前面空了!empty_size!字节的空间，正在填充...
!dd! if=/dev/zero bs=1 count=!empty_size! >> newlogo.img
rem del /s /q empty.tmp > nul
)
!busybox! cat "!n!.bmp" >> newlogo.img
set /a n=n+1
)
goto:eof
