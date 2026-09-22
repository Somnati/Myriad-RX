/// @description stk_tide(at) -> { layer, left } THE TIDE (q317): the wall clock walks a flood over the layers, STK_TIDE_LEN seconds each - energy, aether, quintessence, round again; left = seconds until it moves on
function stk_tide(_at) {
	var _ph = _at mod STK_TIDE_LEN;
	if (_ph < 0) _ph += STK_TIDE_LEN;
	return { layer : floor(_at / STK_TIDE_LEN) mod 3, left : STK_TIDE_LEN - _ph };
}
