/// @description color_to_hex(color);
/// @param color
/// GM color -> "rrggbb", the form the dialogue [color=...] tag reads.
/// lets proc-generated colors (profile colors etc.) flow into tagged text
function color_to_hex(_c){

	var _hx = "0123456789abcdef";
	var _r = colour_get_red(_c);
	var _g = colour_get_green(_c);
	var _b = colour_get_blue(_c);
	return string_char_at(_hx, _r div 16 + 1) + string_char_at(_hx, _r mod 16 + 1)
	     + string_char_at(_hx, _g div 16 + 1) + string_char_at(_hx, _g mod 16 + 1)
	     + string_char_at(_hx, _b div 16 + 1) + string_char_at(_hx, _b mod 16 + 1);

}
