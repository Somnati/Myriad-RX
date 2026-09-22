/// @description stk_cap_cost(s) -> the next energy cap's price in spark: the first x the step^bought, over the ballast
function stk_cap_cost(_s) {
	return ceil(STK_CAP_COST * power(STK_CAP_MULT, _s.cap_lv) / stk_mult(_s, "capcost"));
}
