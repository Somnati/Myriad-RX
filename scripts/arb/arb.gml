/// @description  arb(val);
/// @param val
function arb(argument0) {

	var __val;

	_arb_ = argument0;
	__val = string_length(floor(_arb_))-1;
	if string_length(floor(_arb_)) > 19.9218 __val -= 3;

	return __val + (_arb_/power(10,__val+1));
	

}
