# GdUnit generated TestSuite
class_name AssemblerTest6502
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://tools/6502_assembler.gd'


func test_clean_text() -> void:
	var assem = Assembler6502.new()
	var txt = "  hello\tline\r\n\n\tabc  def"
	assert_array(assem.clean_text(txt)).is_equal(["hello line", "abc  def"])
	assem.free()


func test_get_number() -> void:
	var assem = Assembler6502.new()
	var txt = "asd($10)gh"
	assert_int(assem.get_number(txt)).is_equal(0x10)
	txt = "asd(-$1)gh"
	assert_int(assem.get_number(txt)).is_equal(0xff)
	txt = "asd($fffc)gh"
	assert_int(assem.get_number(txt)).is_equal(0xfffc)
	txt = "asd(-3)gh"
	assert_int(assem.get_number(txt)).is_equal(253)
	txt = "asd(4)gh"
	assert_int(assem.get_number(txt)).is_equal(4)
	txt = "asd(47)gh"
	assert_int(assem.get_number(txt)).is_equal(47)
	txt = "asd(' ')gh"
	assert_int(assem.get_number(txt)).is_equal(32)
	txt = "xcvb"
	assert_int(assem.get_number(txt)).is_equal(-1)
	txt = ""
	assert_int(assem.get_number(txt)).is_equal(-1)
	txt = "  %00001111"
	assert_int(assem.get_number(txt)).is_equal(15)
	assem.free()


func test_replace_labels() -> void:
	var assem = Assembler6502.new()
	assem.labels = { "test": 123, "xyz": 456 }
	assem.ordered_labels = assem.labels.keys()
	assert_str(assem.replace_labels("hello test xyzgjy")).is_equal("hello 123 456gjy")
	assem.free()


func test_is_label() -> void:
	var assem = Assembler6502.new()
	assert_bool(assem.is_label("3")).is_false()
	assert_bool(assem.is_label("#")).is_false()
	assert_bool(assem.is_label("a1")).is_true()
	assert_bool(assem.is_label("z0")).is_true()
	assert_bool(assem.is_label("Apple")).is_true()
	assert_bool(assem.is_label("ZOO")).is_true()
	assem.free()


func test_process_lines_pass1() -> void:
	var assem = Assembler6502.new()
	var lines = [
		"start:  .org  $400",
		"   lda #8",
		"nop:   nop",
		"label:",
		"       .db 1,$f, 'A'",
		"       .ds 32",
		"end:"
	]
	assem.process_lines_pass1(lines)
	assert_bool(assem.labels.has("START")).is_true()
	assert_int(assem.labels["START"]).is_equal(0x400)
	assert_int(assem.labels["NOP"]).is_equal(0x402)
	assert_int(assem.labels["LABEL"]).is_equal(0x403)
	assert_int(assem.labels["END"]).is_equal(0x426)
	lines = [
		"a: LDA A",
		"b: LDA $1000",
		"c: LDA $1000,X",
		"d: LDA $1000,Y",
		"e: LDA #$BB",
		"f: LDA",
		"g: LDA ($LLHH)",
		"h: LDA ($LL,X)",
		"i: LDA ($LL),Y",
		"j: LDA $BB",
		"k: LDA $10",
		"l: LDA $10,X",
		"m: LDA $10,Y",
		"n:"
	]
	assem.process_lines_pass1(lines)
	assert_int(assem.labels["A"]).is_equal(0)
	assert_int(assem.labels["B"]).is_equal(1)
	assert_int(assem.labels["C"]).is_equal(4)
	assert_int(assem.labels["D"]).is_equal(7)
	assert_int(assem.labels["E"]).is_equal(10)
	assert_int(assem.labels["F"]).is_equal(12)
	assert_int(assem.labels["G"]).is_equal(13)
	assert_int(assem.labels["H"]).is_equal(16)
	assert_int(assem.labels["I"]).is_equal(18)
	assert_int(assem.labels["J"]).is_equal(20)
	assert_int(assem.labels["K"]).is_equal(22)
	assert_int(assem.labels["L"]).is_equal(24)
	assert_int(assem.labels["M"]).is_equal(26)
	assert_int(assem.labels["N"]).is_equal(28)
	assem.free()


func test_process_lines_bad_source() -> void:
	var assem = Assembler6502.new()
	var lines = [".org aaaa"]
	var result = assem.process_lines_pass1(lines)
	assert_str(result).is_not_equal("ok")
	lines = ["aaaa"]
	result = assem.process_lines_pass1(lines)
	assert_str(result).is_equal("ok")
	result = assem.process_lines_pass2(lines)
	assert_str(result).is_not_equal("ok")
	assem.free()


func test_process_lines_pass2() -> void:
	var assem = Assembler6502.new()
	var lines = assem.clean_text(program)
	assem.process_lines_pass1(lines)
	assem.process_lines_pass2(lines)
	var bytes = get_bytes_from_dump(dump)
	var start = 0x7000
	var end = start + bytes.size()
	var result = assem.bytes.slice(start, end)
	assert_array(result).is_equal(bytes)
	for idx in bytes.size():
		if bytes[idx] != result[idx]:
			prints(idx, bytes[idx], result[idx])
	print("\n".join(assem.list))
	assem.free()

var program = "; initialise device locations

; device.display $200

; *** _Must_ initialise display ***
; display hardware regs at 0x200
.org $200
; display at 0x300
; palette at palette
; 256 x 192 x 4bpp @ 25fps
.dw $300,palette,256,192,4,25

; *** Reset vector _must_ be set ***
.org $FFFC
.dw start

; Program goes here
.org $7000
start:
; stars will live at $0 and be a 16bit number for position
ldx #0

init:
jsr rand_8
sta 0,x
inx

genagain:
jsr rand_8
cmp #$60
bcs genagain
clc
adc #$3 ; add screen base
sta 0,x
inx

cpx #192
bne init


draw:
ldx #192 ; index
jsr drawloop_clearStars

ldx #128 ; index
jsr drawloop_clearStars

ldx #64 ; index
jsr drawloop_clearStars

end:
jmp draw

drawloop_clearStars:

; clear star
lda #0
sta (0,x)

dec 0,x  ; subtract 1

txa
sta (0,x) ; draw star
dex
dex
bne drawloop_clearStars

frameloop:
lda $210 ; device.display +  16
bne frameloop
rts

; init rng

; rng with 2^32-1 length
rand_8:
asl r_seed
rol r_seed2
rol r_seed3
rol r_seed4
lda r_seed
bcc carry_not_set
eor #$AF
sta r_seed
carry_not_set:

rts

r_seed:
.db 1
r_seed2:
.db 14  ; prng seed byte, must not be zero
r_seed3:
.db 2
r_seed4:
.db 0

; *** Initialise palette ***
palette:
.dl 000000, $444444, $444444, $444444, $444444, $555555, $666666, $666666, $666666, $AAAAAA, $AAAAAA, $bbbbbb, $cccccc, $dddddd, $eeeeee, $ffffff
"

var dump = "7000: a2 00 20 3e 70 95 00 e8 20 3e 70 c9 60 b0 f9 18 
7010: 69 03 95 00 e8 e0 c0 d0 e9 a2 c0 20 2b 70 a2 80 
7020: 20 2b 70 a2 40 20 2b 70 4c 19 70 a9 00 81 00 d6 
7030: 00 8a 81 00 ca ca d0 f3 ad 10 02 d0 fb 60 0e 55 
7040: 70 2e 56 70 2e 57 70 2e 58 70 ad 55 70 90 05 49 
7050: af 8d 55 70 60 01 0e 02 00 00 00 00 00 44 44 44 
7060: 00 44 44 44 00 44 44 44 00 44 44 44 00 55 55 55 
7070: 00 66 66 66 00 66 66 66 00 66 66 66 00 aa aa aa 
7080: 00 aa aa aa 00 bb bb bb 00 cc cc cc 00 dd dd dd 
7090: 00 ee ee ee 00 ff ff ff 00 00 00 00 00 00 00 00"

func get_bytes_from_dump(d):
	d = d.replace("\n", " ")
	var bytes = []
	d = d.split(" ", false)
	for s in d:
		if not s.ends_with(":"):
			bytes.append(s.hex_to_int())
	return bytes
