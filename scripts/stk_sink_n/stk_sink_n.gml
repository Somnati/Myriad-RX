/// @description stk_sink_n(s, l) -> how many of layer l's sinks are OPEN: six, seven with the seventh perk
function stk_sink_n(_s, _l) {
	return (stk_perk(_s, "seventh") > 0) ? 7 : 6;
}
