@echo off
chcp 65001 >nul
REM 动态检测WSL用户名
for /f "delims=" %%i in ('wsl whoami') do set WSLUSER=%%i
echo 检测到 WSL 用户: %WSLUSER%

REM 在WSL下编译
wsl -u %WSLUSER% -- bash -c "cd Kernel && clang++ -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -fno-exceptions -fno-rtti -std=c++17 -c main.cpp -o main.o"
wsl -u %WSLUSER% -- bash -c "cd Kernel && ld.lld --entry KernelMain -z norelro --image-base 0x100000 --static -o kernel.elf main.o"

REM 确保Build目录存在
if not exist Build mkdir Build

REM 拷贝生成的kernel.elf回本地Build目录
copy /b NUL Build\kernel.elf

echo 构建完成：kernel.elf 已复制到 Build 目录。