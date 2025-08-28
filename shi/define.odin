#+feature dynamic-literals
package main

import "core:log"
import "core:slice"
import "core:strings"

/* 
爻顺序从下向上，1为阳爻，0为阴爻
*/

// 初始化卦
@(init, private)
gua_init :: proc() {
	Gua8ArrTmp := Gua8Arr
	for i in 0 ..< Gua8Len {
		Gua8Unicode[i] = '\u2630' + rune(i)
		Gua8Map[Gua8ArrTmp[i]] = Gua8Unicode[i]
	}
	Gua64ArrTmp := Gua64Arr
	for i in 0 ..< Gua64Len {
		Gua64Unicode[i] = '\u4DC0' + rune(i)
		Gua64Map[Gua64ArrTmp[i]] = Gua64Unicode[i]
	}
}

YangYao :: '\u268A'
YinYao :: '\u268B'

// 四象
SiXiang :: enum {
	老阴 = 0b000, // 三面 6，可变, 交×
	少阳 = 0b001, // 两面一背 7, 单
	少阴 = 0b011, // 两背一面 8, 拆
	老阳 = 0b111, // 三背 9，可变, 重□
}
SiXiang_to_string :: proc(s: SiXiang) -> string {
	switch s {
	case .老阳:
		return "老阳"
	case .少阳:
		return "少阳"
	case .少阴:
		return "少阴"
	case .老阴:
		return "老阴"
	}
	return ""
}
SiXiang_arr_to_str :: proc(yaos: ^[6]SiXiang) -> string {
	sb := strings.builder_make(allocator = context.temp_allocator)
	strings.write_byte(&sb, '[')
	for y in yaos {
		strings.write_string(&sb, SiXiang_to_string(y))
		strings.write_byte(&sb, ',')
	}
	strings.write_byte(&sb, ']')
	return strings.to_string(sb)
}

// 处理生成的四象
handle_from_sixiang :: proc(sixiangs: ^[6]SiXiang) {
	log.infof("生成的象={}", SiXiang_arr_to_str(sixiangs))

	// 计算本卦、之卦、爻变数
	bengua_yaos: [6]int = ---
	zhigua_yaos: [6]int = ---
	yao_bian := 0
	for yao, i in sixiangs {
		switch yao {
		case .老阳:
			bengua_yaos[i] = 1
			zhigua_yaos[i] = 0
			yao_bian += 1
		case .少阳:
			bengua_yaos[i] = 1
			zhigua_yaos[i] = 1
		case .少阴:
			zhigua_yaos[i] = 0
			bengua_yaos[i] = 0
		case .老阴:
			bengua_yaos[i] = 0
			zhigua_yaos[i] = 1
			yao_bian += 1
		}
	}
	ben_key := slice_to_bin(&bengua_yaos)
	bengua := Gua64Map[ben_key]
	zhi_key := slice_to_bin(&zhigua_yaos)
	log.infof("benKey={}, bengua_yaos={}, zhikey={}", ben_key, bengua_yaos, zhi_key)
	zhigua := Gua64Map[zhi_key]
	log.infof(
		"本卦={} {}卦, 之卦={} {}卦, 爻变数={}",
		bengua,
		Gua64(ben_key),
		zhigua,
		Gua64(zhi_key),
		yao_bian,
	)
}

// 八卦
// 顺序参见 Gua8
Gua8Len :: 8
// 八卦卦爻
Gua8Arr :: [Gua8Len]int{0b111, 0b110, 0b101, 0b100, 0b011, 0b010, 0b001, 0b000}
// 八卦unicode码
Gua8Unicode: [Gua8Len]rune
// 八卦爻与unicode码映射
Gua8Map: map[int]rune

Gua8 :: enum {
	乾 = Gua8Arr[0],
	兑 = Gua8Arr[1],
	离 = Gua8Arr[2],
	震 = Gua8Arr[3],
	巽 = Gua8Arr[4],
	坎 = Gua8Arr[5],
	艮 = Gua8Arr[6],
	坤 = Gua8Arr[7],
}

// 六十四卦，顺序参见后天卦
Gua64Len :: 64
// 六十四卦卦爻
Gua64Arr :: [64]int {
	// 1.乾 (111111)
	0b111111,
	// 2.坤 (000000)
	0b000000,
	// 3.屯 (100010)
	0b100010,
	// 4.蒙 (010001)
	0b010001,
	// 5.需 (111010)
	0b111010,
	// 6.讼 (010111)
	0b010111,
	// 7.师 (010000)
	0b010000,
	// 8.比 (000010)
	0b000010,
	// 9.小畜 (110111)
	0b110111,
	// 10.履 (111101)
	0b111101,
	// 11.泰 (000111)
	0b000111,
	// 12.否 (111000)
	0b111000,
	// 13.同人 (101111)
	0b101111,
	// 14.大有 (111101)
	0b111101,
	// 15.谦 (000100)
	0b000100,
	// 16.豫 (001000)
	0b001000,
	// 17.随 (100110)
	0b100110,
	// 18.蛊 (011001)
	0b011001,
	// 19.临 (110000)
	0b110000,
	// 20.观 (000011)
	0b000011,
	// 21.噬嗑 (100101)
	0b100101,
	// 22.贲 (101001)
	0b101001,
	// 23.剥 (000001)
	0b000001,
	// 24.复 (100000)
	0b100000,
	// 25.无妄 (100111)
	0b100111,
	// 26.大畜 (111001)
	0b111001,
	// 27.颐 (100001)
	0b100001,
	// 28.大过 (011110)
	0b011110,
	// 29.坎 (010010)
	0b010010,
	// 30.离 (101101)
	0b101101,
	// 31.咸 (001110)
	0b001110,
	// 32.恒 (011100)
	0b011100,
	// 33.遁 (001111)
	0b001111,
	// 34.大壮 (111100)
	0b111100,
	// 35.晋 (000101)
	0b000101,
	// 36.明夷 (101000)
	0b101000,
	// 37.家人 (101011)
	0b101011,
	// 38.睽 (110101)
	0b110101,
	// 39.蹇 (001010)
	0b001010,
	// 40.解 (010100)
	0b010100,
	// 41.损 (110001)
	0b110001,
	// 42.益 (100011)
	0b100011,
	// 43.夬 (111110)
	0b111110,
	// 44.姤 (011111)
	0b011111,
	// 45.萃 (000110)
	0b000110,
	// 46.升 (011000)
	0b011000,
	// 47.困 (010110)
	0b010110,
	// 48.井 (011010)
	0b011010,
	// 49.革 (101110)
	0b101110,
	// 50.鼎 (011101)
	0b011101,
	// 51.震 (100100)
	0b100100,
	// 52.艮 (001001)
	0b001001,
	// 53.渐 (001011)
	0b001011,
	// 54.归妹 (110100)
	0b110100,
	// 55.丰 (101100)
	0b101100,
	// 56.旅 (001101)
	0b001101,
	// 57.巽 (011011)
	0b011011,
	// 58.兑 (110110)
	0b110110,
	// 59.涣 (010011)
	0b010011,
	// 60.节 (110010)
	0b110010,
	// 61.中孚 (110011)
	0b110011,
	// 62.小过 (001100)
	0b001100,
	// 63.既济 (101010)
	0b101010,
	// 64.未济 (010101)
	0b010101,
}
// 六十四卦unicode码
Gua64Unicode: [Gua64Len]rune
// 六十四卦爻与unicode码映射
Gua64Map: map[int]rune

Gua64 :: enum {
	乾  = Gua64Arr[0],
	坤  = Gua64Arr[1],
	屯  = Gua64Arr[2],
	蒙  = Gua64Arr[3],
	需  = Gua64Arr[4],
	讼  = Gua64Arr[5],
	师  = Gua64Arr[6],
	比  = Gua64Arr[7],
	小畜 = Gua64Arr[8],
	履  = Gua64Arr[9],
	泰  = Gua64Arr[10],
	否  = Gua64Arr[11],
	同人 = Gua64Arr[12],
	大有 = Gua64Arr[13],
	谦  = Gua64Arr[14],
	豫  = Gua64Arr[15],
	随  = Gua64Arr[16],
	蛊  = Gua64Arr[17],
	临  = Gua64Arr[18],
	观  = Gua64Arr[19],
	噬嗑 = Gua64Arr[20],
	贲  = Gua64Arr[21],
	剥  = Gua64Arr[22],
	复  = Gua64Arr[23],
	无妄 = Gua64Arr[24],
	大畜 = Gua64Arr[25],
	颐  = Gua64Arr[26],
	大过 = Gua64Arr[27],
	坎  = Gua64Arr[28],
	离  = Gua64Arr[29],
	咸  = Gua64Arr[30],
	恒  = Gua64Arr[31],
	遁  = Gua64Arr[32],
	大壮 = Gua64Arr[33],
	晋  = Gua64Arr[34],
	明夷 = Gua64Arr[35],
	家人 = Gua64Arr[36],
	睽  = Gua64Arr[37],
	蹇  = Gua64Arr[38],
	解  = Gua64Arr[39],
	损  = Gua64Arr[40],
	益  = Gua64Arr[41],
	夬  = Gua64Arr[42],
	姤  = Gua64Arr[43],
	萃  = Gua64Arr[44],
	升  = Gua64Arr[45],
	困  = Gua64Arr[46],
	井  = Gua64Arr[47],
	革  = Gua64Arr[48],
	鼎  = Gua64Arr[49],
	震  = Gua64Arr[50],
	艮  = Gua64Arr[51],
	渐  = Gua64Arr[52],
	归妹 = Gua64Arr[53],
	丰  = Gua64Arr[54],
	旅  = Gua64Arr[55],
	巽  = Gua64Arr[56],
	兑  = Gua64Arr[57],
	涣  = Gua64Arr[58],
	节  = Gua64Arr[59],
	中孚 = Gua64Arr[60],
	小过 = Gua64Arr[61],
	既济 = Gua64Arr[62],
	未济 = Gua64Arr[63],
}
