<!-- :
@echo off
for /f "delims=" %%a in ('mshta "%~f0"') do echo;%%a
:: Changed by affggh
::pause&exit /b
exit /b
:: End Changed
-->

<input type=file id=f>
<script>
f.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(f.value);close();
</script>