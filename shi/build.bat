@echo off

gcc -c rand.c -o rand.o -O3 -mrdseed -nostartfiles
objcopy --remove-section .drectve rand.o
ar rcs rdseed.lib rand.o

odin build . -out:shi.exe

@echo build suc!

@echo.