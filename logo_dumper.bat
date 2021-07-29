:: 作者by 酷安affggh
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
if not defined command cls&color 0c&echo   错误，未定义选项。 &echo    正在退出.... &timeout /t 6 /nobreak>nul&exit /b 1
if /I "%command%"=="extract" call :extract 
if /I "%command%"=="inject" call :inject 
)
exit /b 0
:help
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
goto :eof

:extract
for /f "tokens=1 delims=:" %%i in ('!grep! --only-matching --byte-offset --binary --text --perl-regexp "\x{42}\x{4D}" "!file_input!"') do (
set offset=%%i
set /a blockoffset=!offset!+2
for /f %%i in ('!busybox! xxd -p -s !offset! -l 16 !file_input! ^| findstr /b /n "424d................36000000"') do (
for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set "blocksize=!blocksize: =!"
rem echo blocksize=!blocksize!
echo.&echo  BMP:文件头偏移：!offset!
rem set skipbytes=%%i
rem set /a skipbytes=^(%%i-1^)*16+2
echo.&echo     BMP:读取的数据字节大小偏移：!blockoffset!
rem echo %%j
rem for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo     BMP:读取的数据字节大小：!blocksize!
if not defined n set n=0
set /a n=!n!+1
echo.&echo         试图截取该图片!n!.bmp
if "!offset!"=="0" (
!xxd! -p -l !blocksize! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
) else (
!xxd! -p -s !offset! -l !blocksize! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
)
rem !xxd! -p -s !offset! -l !blocksize! !file_input! | !busybox! tr -d "\n" > !n!.bmp.tmp
)
if not defined offset echo.&echo     #未找到BMP格式的图片...
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
echo.&echo     截取镜像文件头...
!dd! if=!file_input! of=newlogo.img bs=1 count=!offset! 1>nul 2>nul
)

rem 检测图像大小
if not defined n set n=1

if exist "!n!.bmp" (
for %%a in ("!n!.bmp") do set "bmp_size=%%~za"
for %%b in ("newlogo.img") do set "newlogo_size=%%~zb"
rem 加入检测空白区域
set /a "empty_size=!offset!-!newlogo_size!"
)


echo.&echo  BMP:文件头偏移：!offset!
rem set skipbytes=%%i
echo.&echo     BMP:读取的数据字节大小偏移：!blockoffset!
rem echo %%j
rem for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo     BMP:读取的数据字节大小：!blocksize!
echo.&echo         试图注入该图片!n!.bmp
if not "!empty_size!"=="0" (
echo.&echo     BMP:检测到前面空了!empty_size!字节的空间，正在从源文件填充...
!dd! if=!file_input! bs=1 skip=!newlogo_size! count=!empty_size! >> newlogo.img
rem del /s /q empty.tmp > nul
)
echo.&echo     BMP:检测图像是否为BMP格式...
for /f %%i in ('!xxd! -p -l 2 !n!.bmp') do (
if not "%%i"=="424d" echo.&echo     #错误！!n!.bmp这张图片并非是BMP格式！&pause&exit /b 1
if not "!blocksize!"=="!bmp_size!" echo.&echo     #警告！!n!.bmp这张图片大小与源镜像的不符，可能无法显示！&echo.echo     #脚本默认忽略这个错误...&timeout /t 3 /nobreak >nul
)
!busybox! cat "!n!.bmp" >> newlogo.img
set /a n=n+1
for %%i in ("!file_input!") do set original_size=%%~zi
for %%b in ("newlogo.img") do set newlogo_size=%%~zb
set /a footpad_size=!original_size!-!newlogo_size!
)
echo.&echo     #自动检测镜像大小是否相等...
for %%b in ("newlogo.img") do set "newlogo_size=%%~zb"
for %%b in ("!file_input!") do set "original_size=%%~zb"
)
if not "!newlogo_size!"=="!original_size!" ( 
echo.&echo     #警告！文件大小不相等，正在从源文件中拉取填充...
if not exist "!n!.bmp" (
echo.&echo     BMP:检测到还有!footpad_size!大小的字节与源镜像不符
echo.&echo     BMP:自动填充....
!xxd! -p -s !newlogo_size! -l !footpad_size! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r >> newlogo.img
)
) else (
echo     #文件大小相等...
)
goto:eof
