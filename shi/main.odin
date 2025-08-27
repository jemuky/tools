package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "core:strconv"
import win "core:sys/windows"

main :: proc() {
	logger = log.create_console_logger()
	defer log.destroy_console_logger(logger)

	context.logger = logger

	arg_list := os.args
	if len(arg_list) <= 1 {
		log.infof("参数长度不够, 使用 金钱蓍")
		jinqian()
		return
	}
	val, ok := strconv.parse_int(arg_list[1])
	if !ok {
		log.infof("参数解析失败, 使用 金钱蓍")
		jinqian()
		return
	}
	switch val {
	case 0:
		log.infof("使用 金钱蓍")
		jinqian()
	case 1:
		log.infof("使用 蓍草")
		shicao()
	case:
		panic(fmt.tprintf("不支持的值: {}", val))
	}
}

logger: log.Logger

@(init, private)
init :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
	win.SetConsoleOutputCP(.UTF8)
}
