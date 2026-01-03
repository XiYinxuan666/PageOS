@echo off
pushd "%~dp0"
chcp 65001 >nul
REM 动态检测WSL用户名
for /f "delims=" %%i in ('wsl whoami') do set WSLUSER=%%i
echo 检测到 WSL 用户: %WSLUSER%

REM 同步源码到 WSL
wsl -u %WSLUSER% -- rm -rf /home/%WSLUSER%/edk2/PageOS
wsl -u %WSLUSER% -- mkdir -p /home/%WSLUSER%/edk2/PageOS
for /d %%d in (*) do (
    if /I not "%%d"=="Build" (
        wsl -u %WSLUSER% -- cp -r /mnt/c/Users/%USERNAME%/Desktop/workspace/PageOS/%%d /home/%WSLUSER%/edk2/PageOS/
    )
)
for %%f in (*.*) do (
    if /I not "%%f"=="make.bat" if /I not "%%f"=="Build" (
        wsl -u %WSLUSER% -- cp /mnt/c/Users/%USERNAME%/Desktop/workspace/PageOS/%%f /home/%WSLUSER%/edk2/PageOS/
    )
)

REM 在WSL下编译
wsl -u %WSLUSER% -- bash -c "cd /home/%WSLUSER%/edk2/PageOS/Kernel && clang++ -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -fno-exceptions -fno-rtti -std=c++17 -c main.cpp -o main.o"
wsl -u %WSLUSER% -- bash -c "cd /home/%WSLUSER%/edk2/PageOS/Kernel && ld.lld --entry KernelMain -z norelro --image-base 0x200000 --static -o kernel.elf main.o"

REM 确保Build目录存在
if not exist Build mkdir Build

REM 拷贝生成的kernel.elf回本地Build目录
wsl -u %WSLUSER% -- cp /home/%WSLUSER%/edk2/PageOS/Kernel/kernel.elf /mnt/c/Users/%USERNAME%/Desktop/workspace/PageOS/Build/kernel.elf

echo 构建完成：kernel.elf 已复制到 Build 目录。
popd