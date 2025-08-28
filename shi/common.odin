package main

foreign import rdseed "rdseed.lib"

// 真随机
foreign rdseed {
	true_rand :: proc(_: ^u64) -> bool ---
}

// 二进制 [6]int数组转为二进制数字
slice_to_bin :: proc(slice: ^[6]int) -> int {
	result := 0
	for i in 0 ..< 6 {
		result <<= 1
		result |= slice[i]
	}
	return result
}
