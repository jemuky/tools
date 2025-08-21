package main

import "core:log"
import win "core:sys/windows"

foreign import rdseed "rdseed.lib"

foreign rdseed {
	true_rand :: proc(_: ^u64) -> bool ---
}

main :: proc() {
	context.logger = logger

	yin :: false
	yang :: true

	// 掷爻
	sixiangs: [6]SiXiang = ---
	// 掷6次为一卦
	for j in 0 ..< 6 {
		// 一次掷三钱
		tmp: [3]bool = ---
		for i in 0 ..< 3 {
			val: u64 = ---
			for {
				if true_rand(&val) {
					val = val % 2
					break
				}
			}
			tmp[i] = (val == 0 ? yin : yang)
		}
		sixiangs[j] = SiXiang_check(&tmp)
	}
	log.infof("生成的象={}", SiXiang_arr_to_str(&sixiangs))

	// 计算本卦、之卦、爻变数
	benguaYaos: [6]int = ---
	zhiguaYaos: [6]int = ---
	yaoBian := 0
	for yao, i in sixiangs {
		switch yao {
		case .老阳:
			benguaYaos[i] = 1
			zhiguaYaos[i] = 0
			yaoBian += 1
		case .少阳:
			benguaYaos[i] = 1
			zhiguaYaos[i] = 1
		case .少阴:
			zhiguaYaos[i] = 0
			benguaYaos[i] = 0
		case .老阴:
			benguaYaos[i] = 0
			zhiguaYaos[i] = 1
			yaoBian += 1
		}
	}
	benKey := sliceToBin(&benguaYaos)
	bengua := Gua64Map[benKey]
	zhiKey := sliceToBin(&zhiguaYaos)
	zhigua := Gua64Map[zhiKey]
	log.infof(
		"本卦={} {}卦, 之卦={} {}卦, 爻变数={}",
		bengua,
		Gua64(benKey),
		zhigua,
		Gua64(zhiKey),
		yaoBian,
	)
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

logger: log.Logger

@(init, private)
init :: proc() {
	win.SetConsoleOutputCP(.UTF8)

	logger = log.create_console_logger()
}

@(fini, private)
fini :: proc() {
	log.destroy_console_logger(logger)
}
