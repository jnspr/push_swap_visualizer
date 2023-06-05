extends Node2D

var DATA_LENGTH := 512
var STEP_INTERVAL := 1.0 / 768.0 # 768 instructions per second!

var machine: Machine
var data: Array[int]

var insn_ptr: int
var insn_arr: PackedStringArray

var seconds_since_step: float = 0.0

func _ready():
	data.assign(range(DATA_LENGTH))
	data.shuffle()
	get_tree().root.files_dropped.connect(_files_dropped)
	machine = Machine.new(data)

func _draw_stack(stack: Array[int], rect: Rect2, size: Vector2):
	for value in stack:
		var rel_value = float(value) / float(machine.capacity)
		rect.size.x = rel_value * size.x
		draw_rect(rect, Color.from_hsv(rel_value, 1.0, 1.0))
		rect.position.y += size.y

func _draw():
	var view_size := get_viewport_rect()
	var item_size = Vector2(view_size.size.x / 2.0,
							view_size.size.y / machine.capacity)
	_draw_stack(machine.stack_a, Rect2(0, 0, 0, item_size.y), item_size)
	_draw_stack(machine.stack_b, Rect2(item_size.x, 0, 0, item_size.y), item_size)

func _files_dropped(files):
	if len(files) < 1:
		return
	var output: Array
	OS.execute(files[0], data, output)
	insn_arr = output[0].split('\n')
	insn_ptr = 0
	machine = Machine.new(data)

func _process(delta):
	if insn_arr == null:
		return
	seconds_since_step += delta
	if seconds_since_step >= STEP_INTERVAL:
		var num_steps = floor(seconds_since_step / STEP_INTERVAL)
		if num_steps > 1000:
			num_steps = 1000
			seconds_since_step = 0.0
		seconds_since_step -= num_steps * STEP_INTERVAL
		for _step in range(num_steps):
			if insn_ptr < len(insn_arr):
				machine.execute(insn_arr[insn_ptr])
				insn_ptr += 1
		queue_redraw()
