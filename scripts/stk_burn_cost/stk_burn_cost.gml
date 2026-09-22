/// @description stk_burn_cost(s) -> a burn's price in spark: STK_BURN_PRICE of the next cap buy
function stk_burn_cost(_s) {
	return ceil(stk_cap_cost(_s) * STK_BURN_PRICE);
}
