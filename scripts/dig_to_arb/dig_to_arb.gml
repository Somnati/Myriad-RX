/// @description  dig_to_arb(dig);
/// @param dig
function dig_to_arb(argument0) {

	return floor(argument0) + lerp(.1,.99,frac(argument0)*lerp(.05,1,frac(argument0)));

}
