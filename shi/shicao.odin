package main

import "core:fmt"
import "core:log"
import "core:slice"
import "core:time"

/* 
蓍草
*/

shicao :: proc() {
	// 准备50根蓍草(蓍策)，放在圆木筒中
	canister := CircleCanister_new()
	defer CircleCanister_free(&canister)

	// 再准备一个方形木盘，盘中刻两个大槽，大槽左侧又刻三个小槽
	plate := SquarePlate_new()
	defer SquarePlate_free(&plate)

	hands := Hands_new()
	defer Hands_free(&hands)
	// 用右手全取出来
	Hands_rtake_all(&hands, &canister)
	// 用左手取出其中的一根返回木筒中，虚一不用
	Hands_xv1(&hands, &canister)

	// 剩余蓍草总数
	rest_shicao := 49
	// 生成的四象数
	sixiangs: [6]SiXiang = ---

	for j in 1 ..= 6 {
		sixiang: [3]int = ---
		for i in 1 ..= 3 {
			// log.debugf("i={}, rest={}", i, rest_shicao)
			// 用两手随意将剩余的根分为两部分，置于木盘上的左右两大槽中，象征 “天地”阴阳两仪
			// 第一营，分而为二以象两
			SquarePlate_split2(&plate, &hands, rest_shicao)
			// log.debugf(
			// 	"depois de SquarePlate_split2, {} plate left={}, right={}, rest_shicao={}",
			// 	3 * (j - 1) + i,
			// 	len(plate.left_trough.shicao),
			// 	len(plate.right_trough.shicao),
			// 	rest_shicao,
			// )

			// 用左手取出左大槽中的蓍草，再用右手从右大槽的蓍策中取出一根挂在左手手指之间，象征天地人三才
			// 第二营，挂一以象三
			Hands_l_2nd_ce(&hands, &plate)
			// log.debugf("depois de Hands_l_2nd_ce")

			// 用右手四策一组地分算左手的蓍策，称为 “揲四”，象征一年四季
			// 第三营前半，揲之以四以象四时
			// 将 “揲四”所余的蓍策夹在左手无名指间，象征闰月
			// 第四营前半，归奇于扐以象闰
			Hands_r_split_l(&hands, &plate)
			// log.debugf("depois de Hands_r_split_l")

			// 用右手将揲过蓍策放回木盘上的左大槽，并取出右大槽中的蓍策，用左手四策一组地分算右手的蓍策
			// 第三营后半
			// 将 “揲四”所余的蓍策夹在左手中指间，象征岁时五年之后出现第二次 “闰月”
			// 第四营后半，五岁再闰，故再扐而后挂
			// 四营完成
			Hands_l_split_r(&hands, &plate)
			// log.debugf("depois de Hands_l_split_r")

			// 右手剩余 过揲之策 放回右大槽，将左手指间一挂二扐之策放在木盘左侧第一小槽
			// 一变
			// 这时，两次夹扐的余策，左大槽若余一策则右大槽必余三策，左余二策则右亦二策，左余三策则右必一策，左余四策则右亦四策；合 “一挂二扐”之策，则非五即九，即为 “一变”的结果
			bian := Hands_bian(&hands, &plate)
			log.infof("{} 变={}", 3 * (j - 1) + i, bian)

			// 将盘中全部取出来，合为一体
			Hands_rtakeall_from_plate(&hands, &plate)
			rest_shicao = Hand_mlen(&hands.right_hand)
			// log.debugf(
			// 	"{} hands len={}, plate left={}, right={}, rest_shicao={}",
			// 	3 * (j - 1) + i,
			// 	len(hands.right_hand.middle),
			// 	len(plate.left_trough.shicao),
			// 	len(plate.right_trough.shicao),
			// 	rest_shicao,
			// )
			sixiang[i - 1] = bian
		}
		sixiangs[j - 1] = ShicaoSiXiang_check(&sixiang)

		rest_shicao = 49
		// 清空所有蓍草，全部放在右手中
		Hands_reset(&hands, &plate)
	}

	// 处理生成的四象
	handle_from_sixiang(&sixiangs)
}

// 处理四象值
ShicaoSiXiang_check :: proc(sixiang: ^[3]int) -> SiXiang {
	sum := 0
	for v in sixiang {
		sum += v
	}
	sub := 49 - sum

	switch sub / 4 {
	case 6:
		return .老阴
	case 7:
		return .少阳
	case 8:
		return .少阴
	case 9:
		return .老阳
	case:
		panic(fmt.tprintf("程序错误，不期望的结果({})", sub / 4))
	}
}

Hands :: struct {
	left_hand:  Hand,
	right_hand: Hand,
}

Hands_new :: proc() -> Hands {
	return {left_hand = Hand_new("左手"), right_hand = Hand_new("右手")}
}

Hands_free :: proc(th: ^Hands) {
	Hand_free(&th.left_hand)
	Hand_free(&th.right_hand)
}

Hands_clear :: proc(th: ^Hands) {
	Hand_clear(&th.left_hand)
	Hand_clear(&th.right_hand)
}

// 虚一不用
Hands_xv1 :: proc(th: ^Hands, cc: ^CircleCanister) {
	if Hand_mlen(&th.right_hand) != 50 do panic(fmt.tprintf("未从筒中取出蓍草, 当前数量: {}", len(th.right_hand.middle)))

	// 用左手取出其中的一根返回木筒中
	Hand_1take(&th.left_hand)
	CircleCanister_xv1(cc)
	Hand_1pop(&th.left_hand)
	// 右手手中数量减去一根
	Hand_mpop(&th.right_hand)
}

// 从筒中取出所有到右手上
Hands_rtake_all :: proc(th: ^Hands, cc: ^CircleCanister) {
	Hand_mtake(&th.right_hand, len(cc.fifty_shicao))
	CircleCanister_clear(cc)
}

// 用左手取出左大槽中的蓍草，再用右手从右大槽的蓍策中取出一根挂在左手手指之间
Hands_l_2nd_ce :: proc(th: ^Hands, sp: ^SquarePlate) {
	// 用左手取出左大槽中的蓍草
	Hand_mtake(&th.left_hand, SquarePlateTrough_len(&sp.left_trough))
	SquarePlateTrough_clear(&sp.left_trough)

	// 用右手从右大槽的蓍策中取出一根挂在左手手指之间
	Hand_1take(&th.right_hand)
	SquarePlateTrough_pop(&sp.right_trough)
	Hand_2take(&th.left_hand)
	Hand_1pop(&th.right_hand)
}

// 用右手四策一组地分算左手的蓍策, 称为 “揲四”， 将 “揲四”所余的蓍策夹在左手无名指间
Hands_r_split_l :: proc(th: ^Hands, sp: ^SquarePlate) {
	// 慢慢分算
	for Hand_mlen(&th.left_hand) > 4 {
		Hand_mtake(&th.right_hand, 4)
		Hand_mpop_n(&th.left_hand, 4)
	}

	// 将 “揲四”所余的蓍策夹在左手无名指间
	Hand_4take(&th.left_hand, Hand_mlen(&th.left_hand))
	Hand_mclear(&th.left_hand)
}

// 用右手将揲过蓍策放回木盘上的左大槽，并取出右大槽中的蓍策，用左手四策一组地分算右手的蓍策
// 将 “揲四”所余的蓍策夹在左手中指间
Hands_l_split_r :: proc(th: ^Hands, sp: ^SquarePlate) {
	// 用右手将揲过蓍策放回木盘上的左大槽
	SquarePlateTrough_place_n(&sp.left_trough, Hand_mlen(&th.right_hand))
	Hand_mpop_n(&th.right_hand, Hand_mlen(&th.right_hand))

	// 取出右大槽中的蓍策
	Hand_mtake(&th.right_hand, SquarePlateTrough_len(&sp.right_trough))
	SquarePlateTrough_clear(&sp.right_trough)

	// 用左手四策一组分算
	for Hand_mlen(&th.right_hand) > 4 {
		Hand_mtake(&th.left_hand, 4)
		Hand_mpop_n(&th.right_hand, 4)
	}

	// 将 “揲四”所余的蓍策夹在左手中指间
	Hand_3take(&th.left_hand, Hand_mlen(&th.right_hand))
	Hand_mclear(&th.right_hand)
}

// 右手(应为左手)剩余 过揲之策 放回右大槽，将左手指间一挂二扐之策放在木盘左侧第一小槽
Hands_bian :: proc(h: ^Hands, sp: ^SquarePlate) -> int {
	// 放回右大槽
	SquarePlateTrough_place_n(&sp.right_trough, Hand_mlen(&h.left_hand))
	Hand_mclear(&h.left_hand)

	// 将左手指间一挂二扐之策放在木盘左侧第一小槽
	// log.debugf(
	// 	"食指={}, 中指={}, 无名指={}",
	// 	len(h.left_hand.ui_vs),
	// 	len(h.left_hand.vs_wumy),
	// 	len(h.left_hand.wumy_xc),
	// )
	ce_len := Hand_gl_len(&h.left_hand)
	SquarePlateTrough_place_n(&sp.strough1, ce_len)
	Hand_clear_guale(&h.left_hand)
	return ce_len
}

// 将盘中全部取出来，合为一体到右手
Hands_rtakeall_from_plate :: proc(h: ^Hands, sp: ^SquarePlate) {
	Hand_mtake(&h.right_hand, SquarePlateTrough_len(&sp.left_trough))
	Hand_mtake(&h.right_hand, SquarePlateTrough_len(&sp.right_trough))
	SquarePlateTrough_clear(&sp.left_trough)
	SquarePlateTrough_clear(&sp.right_trough)
}

// 除了虚一，清空所有蓍草，全部放在右手中
Hands_reset :: proc(h: ^Hands, sp: ^SquarePlate) {
	SquarePlate_clear(sp)
	Hands_clear(h)
	Hand_mtake(&h.right_hand, 49)
}

Hand :: struct {
	// 手名
	name:    string,
	// 手中间
	middle:  [dynamic]bool,
	// 手夹缝
	da_ui:   [dynamic]bool, // 大拇指、食指间
	ui_vs:   [dynamic]bool, // 食指、中指间
	vs_wumy: [dynamic]bool, // 中指、无名指间
	wumy_xc: [dynamic]bool, // 无名指、小指间
}

// 一挂二扐的总数量
Hand_gl_len :: proc(hand: ^Hand) -> int {
	return len(hand.ui_vs) + len(hand.vs_wumy) + len(hand.wumy_xc)
}

// 清除一挂二扐的蓍草
Hand_clear_guale :: proc(hand: ^Hand) {
	Hand_2pop(hand)
	Hand_3clear(hand)
	Hand_4clear(hand)
}

Hand_mlen :: proc(hand: ^Hand) -> int {
	return len(hand.middle)
}

// 手指拿一个，用大拇指、食指拿
Hand_1take :: proc(hand: ^Hand) {
	append(&hand.da_ui, true)
}

// 大拇指、食指间去除一个
Hand_1pop :: proc(hand: ^Hand) {
	if len(hand.da_ui) >= 1 {
		pop(&hand.da_ui)
	} else {
		log.warnf("{:s} 去除da_ui时, 数量({})不够! ", hand.name, len(hand.da_ui))
	}
}

// 食指、中指间挂一个
Hand_2take :: proc(hand: ^Hand) {
	append(&hand.ui_vs, true)
}
// 食指、中指间去除一个
Hand_2pop :: proc(hand: ^Hand) {
	pop_safe(&hand.ui_vs)
}

// 中指、无名指间挂n个
Hand_3take :: proc(hand: ^Hand, n: int) {
	vs_wumy := make([]bool, n, allocator = context.temp_allocator)
	for i in 0 ..< n {
		vs_wumy[i] = true
	}
	append(&hand.vs_wumy, ..vs_wumy)
}
// 清除中指、无名指间蓍草
Hand_3clear :: proc(hand: ^Hand) {
	clear(&hand.vs_wumy)
}

// 无名指、小指间挂n个
Hand_4take :: proc(hand: ^Hand, n: int) {
	wumy_xc := make([]bool, n, allocator = context.temp_allocator)
	for i in 0 ..< n {
		wumy_xc[i] = true
	}
	append(&hand.wumy_xc, ..wumy_xc)
}
// 清除无名指、小指间蓍草
Hand_4clear :: proc(hand: ^Hand) {
	clear(&hand.wumy_xc)
}

// 从手中删除
Hand_mpop :: proc(hand: ^Hand) {
	if Hand_mlen(hand) >= 1 {
		pop(&hand.middle)
	} else {
		log.warnf("{:s} 去除middle时, 数量({})不够! ", hand.name, len(hand.middle))
	}
}

// 从手中去除n个
Hand_mpop_n :: proc(hand: ^Hand, n: int) {
	if Hand_mlen(hand) >= n {
		for _ in 0 ..< n {
			pop(&hand.middle)
		}
	} else {
		log.warnf(
			"{:s} 去除middle时, 应去除{}个, 数量({})不够! ",
			hand.name,
			n,
			len(hand.middle),
		)
	}
}

// 放到手中 num 个
Hand_mtake :: proc(hand: ^Hand, num: int) {
	for _ in 0 ..< num {
		append(&hand.middle, true)
	}
}


Hand_new :: proc(name: string) -> Hand {
	return {
		name = name,
		middle = make([dynamic]bool),
		da_ui = make([dynamic]bool),
		ui_vs = make([dynamic]bool),
		vs_wumy = make([dynamic]bool),
		wumy_xc = make([dynamic]bool),
	}
}

// 只去除手中的
Hand_mclear :: proc(hand: ^Hand) {
	clear(&hand.middle)
}

Hand_clear :: proc(hand: ^Hand) {
	clear(&hand.middle)
	clear(&hand.da_ui)
	clear(&hand.ui_vs)
	clear(&hand.vs_wumy)
	clear(&hand.wumy_xc)
}

Hand_free :: proc(hand: ^Hand) {
	delete(hand.middle)
	delete(hand.da_ui)
	delete(hand.ui_vs)
	delete(hand.vs_wumy)
	delete(hand.wumy_xc)
}

// 圆木筒中，50根蓍草
CircleCanister :: struct {
	fifty_shicao: [dynamic]bool,
}

CircleCanister_new :: proc() -> CircleCanister {
	cc := CircleCanister{}
	CircleCanister_reset(&cc)
	return cc
}

CircleCanister_reset :: proc(cc: ^CircleCanister) {
	if cc.fifty_shicao != nil do free(&cc.fifty_shicao)
	cc.fifty_shicao = make([dynamic]bool, 50, 50)
	for i in 0 ..< 50 {
		cc.fifty_shicao[i] = true
	}
}

CircleCanister_clear :: proc(cc: ^CircleCanister) {
	clear(&cc.fifty_shicao)
}

CircleCanister_free :: proc(cc: ^CircleCanister) {
	delete(cc.fifty_shicao)
}

// 虚一不用
CircleCanister_xv1 :: proc(cc: ^CircleCanister) {
	append(&cc.fifty_shicao, true)
}

// 方形木盘，盘中刻两个大槽，大槽左侧又刻三个小槽
SquarePlate :: struct {
	strough1:     SquarePlateTrough,
	strough2:     SquarePlateTrough,
	strough3:     SquarePlateTrough,
	left_trough:  SquarePlateTrough,
	right_trough: SquarePlateTrough,
}

// 用两手随意将剩余的49根分为两部分(左右手至少为1根)，置于木盘上的左右两大槽
SquarePlate_split2 :: proc(sp: ^SquarePlate, th: ^Hands, rest: int) {
	val: u64 = ---
	for !true_rand(&val) do time.sleep(time.Millisecond)

	// 左手数量
	left_num := int(val % u64(rest - 1))
	// 右手数量
	right_num := rest - left_num

	// log.debugf(
	// 	"leftnum={}, rightnum={}, rest={}, leftplate={}, rightplate={}",
	// 	left_num,
	// 	right_num,
	// 	rest,
	// 	SquarePlateTrough_len(&sp.left_trough),
	// 	SquarePlateTrough_len(&sp.right_trough),
	// )
	// 从右手拿出 left_num 个加到左手中
	Hand_mpop_n(&th.right_hand, left_num)
	Hand_mtake(&th.left_hand, left_num)

	// 置于左右两大槽，并从左右手中去除
	SquarePlateTrough_place_n(&sp.left_trough, left_num)
	Hand_mclear(&th.left_hand)
	SquarePlateTrough_place_n(&sp.right_trough, right_num)
	Hand_mclear(&th.right_hand)
}

SquarePlate_new :: proc() -> SquarePlate {
	return {
		strough1 = SquarePlateTrough_new(),
		strough2 = SquarePlateTrough_new(),
		strough3 = SquarePlateTrough_new(),
		left_trough = SquarePlateTrough_new(),
		right_trough = SquarePlateTrough_new(),
	}
}

SquarePlate_clear :: proc(sp: ^SquarePlate) {
	SquarePlateTrough_clear(&sp.strough1)
	SquarePlateTrough_clear(&sp.strough2)
	SquarePlateTrough_clear(&sp.strough3)
	SquarePlateTrough_clear(&sp.left_trough)
	SquarePlateTrough_clear(&sp.right_trough)
}

SquarePlate_free :: proc(sp: ^SquarePlate) {
	SquarePlateTrough_free(&sp.strough1)
	SquarePlateTrough_free(&sp.strough2)
	SquarePlateTrough_free(&sp.strough3)
	SquarePlateTrough_free(&sp.left_trough)
	SquarePlateTrough_free(&sp.right_trough)
}

// 槽
SquarePlateTrough :: struct {
	shicao: [dynamic]bool,
}

// 槽中放置n个
SquarePlateTrough_place_n :: proc(spt: ^SquarePlateTrough, n: int) {
	if spt.shicao != nil do clear(&spt.shicao)
	spt.shicao = make([dynamic]bool, n, allocator = context.temp_allocator)
	for i in 0 ..< n {
		spt.shicao[i] = true
	}
}

SquarePlateTrough_len :: proc(spt: ^SquarePlateTrough) -> int {
	return len(spt.shicao)
}

SquarePlateTrough_clear :: proc(spt: ^SquarePlateTrough) {
	clear(&spt.shicao)
}

SquarePlateTrough_pop :: proc(spt: ^SquarePlateTrough) {
	pop(&spt.shicao)
}

SquarePlateTrough_new :: proc() -> SquarePlateTrough {
	return {shicao = make([dynamic]bool)}
}

SquarePlateTrough_free :: proc(spt: ^SquarePlateTrough) {
	delete(spt.shicao)
}
