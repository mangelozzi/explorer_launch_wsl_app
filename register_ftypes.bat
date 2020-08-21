:: This batch script associates the files in %list% with the `txtfile` type, and
:: changes the `txtfile` type to open with with %myscrip%.
:: It does not make it the default app.
:: One can't programmatically change the default file association of an already
:: associated filetype in Windows 10 after the first login without the gui,
:: this is by design for security.

@echo off
echo !!! THIS SCRIPT MUST BE RUN AS ADMIN !!!

:: === REQUIRED CUSTOM VALUES ==================================================

:: A space separated list of extensions to be associated with the `txtfile` type
set list=css gitignore html ini js json lua log markdown md php py render sass scss template text txt xml

:: Set myscript to the double quote filepath of the script to run
:: %~dp0 is the dir of this script file
set myscript="%~dp0wsl_nvim.bat"

:: =============================================================================

:: e.g. require the same as if one typed into cmd: ftype txtfile="C:\current dir\wsl_nvim.bat" "%1"
echo:
echo Create a `ftype` called `txtfile` and assign it to run with WSL NVIM:"
ftype txtfile=%myscript% "%%1"

echo:
echo `ftype` set for `txtfile`, let's check its set:
ftype | findstr "txtfile"

echo:
echo Create a `assoc` between extensions in %list% with `txtfile`
(for %%a in (%list%) do (
   assoc .%%a=txtfile
))

:: Associate files with no extensions
assoc .=txtfile

echo:
echo `assoc` set for each extension, lets check `assoc`:
assoc | findstr ".txt"

echo:
echo Now if you right click on one of these file extensions, and select `Open with`,
echo and select `choose another app`, it should list %myscript% there.
echo SCRIPT COMPLETE.
pause
