@echo off&setlocal ENABLEDELAYEDEXPANSION
color 0b
set choosefile=tools\choosefile.bat
title С��logo�������ע��ű�
:menu
cls
echo.&echo.  ���߿ᰲ affggh �����Ҳϲ���ĵ�һ�����Լ��ҵ��о�Ⱥ��600388679

echo.&echo.  ʹ�÷�����ѡ��1��2ѡ�Ҫѡ��ٷ�logo���˹�����ͨ����̬��ȡ�ٷ�logo
echo.&echo.            �ﵽ���޸ĵ�һ����Ч��...
echo.&echo.                     ��  ��
echo.&echo.             ��1������һ��logo.img
echo.&echo.             ��2����������ͼƬע��logo.img
echo.&echo.             ��3���鿴�����а���...
set INPUT=
echo.&set /p INPUT=-^-^>ѡһ���ɳ��ܵ�
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
if defined INPUT ( echo ���ȣ�12����ѡ�ǵô��ģ�
) else (
echo ���ȣ�ѡ��ûѡ��
)
pause
goto :menu
