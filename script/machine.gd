class_name Machine
extends RefCounted

var stack_a: Array[int]
var stack_b: Array[int]
var maximum: int
var capacity: int

func _init(input: Array[int]):
	stack_a = input.duplicate()
	stack_b = []
	maximum = stack_a.max()
	capacity = stack_a.size()

func execute(instruction: String):
	var routine = INSN_ROUTINES.get(instruction)
	if routine != null:
		routine.call()

var INSN_ROUTINES = {
	'sa': func(): _swap(stack_a),
	'sb': func(): _swap(stack_b),
	'ss': func():
		_swap(stack_a)
		_swap(stack_b),
	'pa': func(): _push(stack_b, stack_a),
	'pb': func(): _push(stack_a, stack_b),
	'ra': func(): _rotate(stack_a),
	'rb': func(): _rotate(stack_b),
	'rr': func():
		_rotate(stack_a)
		_rotate(stack_b),
	'rra': func():
		_reverse_rotate(stack_a),
	'rrb': func():
		_reverse_rotate(stack_b),
	'rrr': func():
		_reverse_rotate(stack_a)
		_reverse_rotate(stack_b)
}

func _swap(stack: Array[int]):
	if len(stack) >= 2:
		var temp := stack[0]
		stack[0] = stack[1]
		stack[1] = temp

func _push(from: Array[int], to: Array[int]):
	if len(from) >= 1:
		to.push_front(from.pop_front())

func _rotate(stack: Array[int]):
	if len(stack) >= 2:
		stack.push_back(stack.pop_front())

func _reverse_rotate(stack: Array[int]):
	if len(stack) >= 2:
		stack.push_front(stack.pop_back())
