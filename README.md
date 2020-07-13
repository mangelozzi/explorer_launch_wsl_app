# Script to enable double click a file in explorer and launch/run it with a WSL App (Neovim, Vim, etc) within Windows Terminal

https://stackoverflow.com/questions/62876681/script-to-open-a-file-in-explorer-with-wsl-app-neovim-vim-etc-and-have-it-ru/62876682#62876682

## TL;DR
Associate the file type with running this batch script (set `myapp` accordingly):
```batch
@echo off
set my_app=nvim
set my_wt_profile="Ubuntu-20.04"
set pp=%1
set pp=%pp:'='\''%
set pp=%pp:;=\;%
set launch="p=$(wslpath '%pp:"=%') && cd \\"^""$(dirname \\"^""$p\\"^"")\\"^"" && %my_app% \\"^""$p\\"^""
start wt.exe new-tab -p %my_wt_profile% bash -i -c %launch%
```

## Intro
Unfortunately one cannot associate a powershell script with file type (via `open with` &rarr;  `choose another app` &rarr; `Look for another app on this pc`). Choose to write a batch file, and put all the logic in there. It would have been easier to create a bash script, or vim plugin on file load, but then there are 2 parts of the puzzle which need to be in syn with each other.

Perform the following steps:
1. Create a batch file and paste in the following code (we will refer to this script as the "launch script", I named it `wsl_nvim.bat`):

Note: The following code is the same as the TL;DR version but with comments:
```
:: This batch script is ment to be associated with file types, such that when
:: the associated file type is opened, it calls this script.
:: This script then open it with Neovim within WSL in a windows terminal (wt).


:: If require a " in the bash command, escape it with \\"^""
:: Example1: To print in bash via cmd the following string: hel'lo
:: bash -i -c "echo "^""hel'lo"^"" "
:: Example2: To print in bash via cmd via wt.exe: hel'lo
:: wt.exe new-tab -p "Command Prompt" cmd /k bash -i -c "echo \\"^""hel'lo\\"^"" "
::
:: To cd to the parent dir: cd "$(dirname "$p")"
:: Escaping it becomes:     cd \"^""$(dirname \"^""$p\"^"")\"^""

@echo off

:: === REQUIRED CUSTOM VALUES ==================================================

:: The name of the WSL app to run
set my_app=nvim

:: The name of your windows terminal linux profile, open the windows terminal
:: settings file and file the linx profile name, e.g.: "name": "Ubuntu-20.04",
set my_wt_profile="Ubuntu-20.04"

:: =============================================================================

:: Windows passes in the filepath in double quotes, e.g.: "C:\Users\Michael\foo.txt"
set pp=%1

:: We passing the path into bash, which has $ and \, so we pass within single quotes
:: so all chars will be taken literally, except the single quote, which we can
:: escape with '\''
set pp=%pp:'='\''%

:: When wt.exe interprets the string, need to escape the semicolon with \;
set pp=%pp:;=\;%

:: Launch basically does: pass in $p, get wslpath of $p, then cd to the dir
:: of the wslpath, then open wslpath with nvim.
:: wslpath requires the input to be within single quotes, or else it will fail.
:: full wt.exe path: %LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe
:: GIANT GOTCHA! Can only strip outter double quotes from %pp% if placing within
:: double quotes, else special chars will be interpretted literally, e.g. ^ will escape.
set launch="p=$(wslpath '%pp:"=%') && cd \\"^""$(dirname \\"^""$p\\"^"")\\"^"" && %my_app% \\"^""$p\\"^""

:: Use `start` to launch cmd and cleanup/close the parent process immediately.
:: bash -i starts bash interactively.
:: bash -c "long command" start bash and allow one to pass in a command to run.
start wt.exe new-tab -p %my_wt_profile% bash -i -c %launch%
```

## Bonus 1 - Associate "launch script" with text file types

Let's make the batch script available as an option in the explorer.exe's right click `Open with` options. Under `Open with` one may have to select `choose another app` and scroll down, which is still much easier than hunting the filesystem for the batch script for each new file type.

Perform the following steps:
1. Copy the following batch script and paste it into a file in the same dir as the above script.
2. Change the value of `myscript` to point to the "launch script" name you choose.
3. Save and close the batch script.
4. Right click on the batch script and select `Run as administrator`
```batch
:: This batch script associates the files in %list% with the `txtfile` type, and
:: changes the `txtfile` type to open with with %myscrip%.
:: It does not make it the default app.
:: One can't programmatically change the default file association of an already
:: associated filetype in Windows 10 after the first login without the gui,
:: this is by design for security.

@echo off
echo !!! THIS SCRIPT MUST BE RUN AS ADMIN !!!

:: === CUSTOM VALUES START =====================================================

:: A space separated list of extensions to be associated with the `txtfile` type
set list=css gitignore html ini js json lua log markdown md php py render sass scss template text txt xml

:: Set myscript to the double quote filepath of the script to run
:: %~dp0 is the dir of this script file
set myscript="%~dp0wsl_nvim.bat"

:: === CUSTOM VALUES END =======================================================

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

echo:
echo `assoc` set for each extension, lets check `assoc`:
assoc | findstr ".txt"

echo:
echo Now if you right click on one of these file extensions, and select `Open with`,
echo and select `choose another app`, it should list %myscript% there.
echo SCRIPT COMPLETE.
pause
```

## Bonus 2 - Create a Taskbar shortcut

1. Copy the "launch script" path.
2. In explorer right click `New` &rarr; `Shortcut`.
3. Type in a suitable name, e.g. `WSL NVIM`
4. Now if one right clicks on the newly created shortcut, there is **_no_** option to pin to taskbar or start.
5. Right click on the shortcut, select `Properties` and change the `target` field to (make sure to customise **_both_** paths!):
    ```
    cmd.exe /s /c ""C:\path\to\launch\script\wsl_nvim.bat" "\\wsl$\Ubuntu-20.04\desirable\default\location\temp_filename""
    ```
    For me the above looks like :
    ```
    cmd.exe /s /c ""C:\code\software_setup\utils\wsl_nvim.bat" "\\wsl$\Ubuntu-20.04\home\michael\temp""
    ```

Now if you double click the shortcut, it should open the wsl app with a blank file in the given location, with temp file name (depending on how your app handles paths). You can now right click on the shortcut and pin it to the taskbar or start menu.
