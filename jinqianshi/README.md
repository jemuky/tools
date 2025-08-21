# 用途

使用金钱蓍来摇卦

# 用法
需安装gcc和odin语言环境  
```shell
# 编译出真随机包
# 编译rand.c
gcc -c rand.c -o rand.o -O3 -mrdseed -nostartfiles
# 去除多余的 .drectve 节
objcopy --remove-section .drectve rand.o
# 生成静态库
ar rcs rdseed.lib rand.o

# odin本体编译
odin build . -out:金钱蓍.exe

# 执行
./金钱蓍.exe
```
