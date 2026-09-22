/// @description stk_focus_on(s) -> the focused sink's speed: STK_FOCUS_ON + .25 a rank of sharper focus
function stk_focus_on(_s) {
	return STK_FOCUS_ON + .25 * stk_perk(_s, "focus");
}
