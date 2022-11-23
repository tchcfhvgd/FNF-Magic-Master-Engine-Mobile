@echo off

cd crash-dialog
haxe hxwidgets-windows.hxml
copy build\windows\Main.exe ..\export\release\windows\bin\Crash-Dialog.exe
cd ..

@echo on