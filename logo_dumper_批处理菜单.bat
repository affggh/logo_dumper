@echo off&setlocal ENABLEDELAYEDEXPANSION
color 0b
set choosefile=tools\choosefile.bat
title 小米logo镜像解析注入脚本
:menu
cls
echo.&echo.  作者酷安 affggh 如果你也喜欢改第一屏可以加我的研究群：600388679

echo.&echo.  使用方法：选择1，2选项都要选择官方logo，此工具是通过动态截取官方logo
echo.&echo.            达到的修改第一屏的效果...
echo.&echo.                     菜  单
echo.&echo.             【1】解析一个logo.img
echo.&echo.             【2】将解析的图片注入logo.img
echo.&echo.             【3】查看命令行帮助...
set INPUT=
echo.&set /p INPUT=-^-^>选一个吧臭弟弟
if /I "%INPUT%"=="1" (
for /f %%i in ('!choosefile!') do set file=%%i
call logo_dumper.bat !file! extract
pause
goto menu
)
if /I "%INPUT%"=="2" (
for /f %%i in ('!choosefile!') do set file=%%i
call logo_dumper.bat !file! inject
pause
goto :menu
)
if /I "%INPUT%"=="3" (
call logo_dumper.bat help
pause
goto :menu
)
if defined INPUT ( echo 笨比，12不会选非得打别的？
) else (
echo 笨比，选都没选？
)
pause
goto :menu
