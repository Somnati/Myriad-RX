/// @description get_ap(var, [ap]) - one ability's AP contribution,
/// ported from Myriad. an ENABLED ability (1) subtracts its cost
/// from g.ap; anything discovered adds to g.curap_spend (the "could
/// spend" total); every visible row bumps mx (the scrollbar count).
function get_ap(_var, _ap = 0) {
	if (_var == -1) exit;
	if (_var == 1) g.ap -= floor(_ap * ap_multi);
	g.curap_spend += floor(_ap * ap_multi);
	mx++;
}
