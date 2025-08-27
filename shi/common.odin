package main

foreign import rdseed "rdseed.lib"

// 真随机
foreign rdseed {
	true_rand :: proc(_: ^u64) -> bool ---
}

// 二进制 [6]int数组转为二进制数字
sliceToBin :: proc(slice: ^[6]int) -> int {
	result := 0
	for i := 5; i >= 0; i -= 1 {
		result <<= 1
		result |= slice[i]
	}
	return result
}
