package main

import "core:fmt"
import "core:log"
import "core:time"

/* 
金钱蓍
*/

jinqian :: proc() {
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
			for !true_rand(&val) {
				time.sleep(time.Millisecond)
			}
			val = val % 2
			tmp[i] = (val == 0 ? yin : yang)
		}
		sixiangs[j] = SiXiang_check(&tmp)
	}
	// 处理生成的四象
	handle_from_sixiang(&sixiangs)
}

// 检查掷得单次结果
SiXiang_check :: proc(threeYao: ^[3]bool) -> SiXiang {
	yangCnt := 0
	for v in threeYao {
		if v {
			yangCnt += 1
			continue
		}
	}
	switch yangCnt {
	case 3:
		return .老阳
	case 2:
		return .少阴
	case 1:
		return .少阳
	case 0:
		return .老阴
	case:
		panic(fmt.tprintf("程序错误，不期望的结果({})", yangCnt))
	}
}

// 处理生成的四象
handle_from_sixiang :: proc(sixiangs: ^[6]SiXiang) {
	log.infof("生成的象={}", SiXiang_arr_to_str(sixiangs))

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
