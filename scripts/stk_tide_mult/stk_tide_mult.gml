/// @description stk_tide_mult(s) -> the flood's speed: STK_TIDE_MULT + .5 a rank of tidewatch
function stk_tide_mult(_s) {
	return STK_TIDE_MULT + .5 * stk_perk(_s, "tidewatch");
}
