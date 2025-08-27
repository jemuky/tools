# 用途

摇卦，分为金钱蓍和蓍草

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

# 程序本体编译
odin build . -out:shi.exe

# 执行
# type可以为0或1, 如 `./shi.exe 0`
#   0代表使用金钱蓍
#   1代表使用蓍草
./shi.exe [type]
```
