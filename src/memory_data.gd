extends Resource

class_name MemoryData

var _mem_size = 0

@export var mem_size: int:
	set(v):
		set_mem_size(v)
@export var width: int = 8
@export var words:PackedInt32Array
@export var ram: bool = false

const mem_sizes = {
	32: "32",
	64: "64",
	128: "128",
	256: "256",
	512: "512",
	1024: "1K",
	2048: "2K",
	4096: "4K",
	8192: "8K"
}

func set_mem_size(v):
	_mem_size = v
	var old_size = words.size()
	words.resize(_mem_size)
	if _mem_size > old_size:
		for idx in range(old_size, _mem_size):
			words[idx] = 0


func fill():
	for idx in _mem_size:
		words[idx] = (idx + 1) % _mem_size


func trim():
	var lim = 0x100 if width == 8 else 0x10000
	for idx in _mem_size:
		words[idx] %= lim


func erase() -> bool:
	var updated = false
	for idx in _mem_size:
		if words[idx] > 0:
			updated = true
		words[idx] = 0
	return updated


func set_indexed_mem_size(idx):
	set_mem_size(mem_sizes.keys()[idx])


func get_mem_size_str():
	return mem_sizes[_mem_size]
