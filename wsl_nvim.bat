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
