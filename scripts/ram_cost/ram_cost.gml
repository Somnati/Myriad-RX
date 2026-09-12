/// @description ram_cost(kind, [v]) - what one automation costs in
/// sticks, THE one price list (the panel's hover preview, the overview
/// and ram_used all read it; a price that lived in two places would
/// disagree the day one moved).
/// @param kind   "timer"   v = seconds between attempts: 1s is 4 sticks,
///                         2s 3, 3-5s 2, slower 1 - speed is what costs
///               "speed"   v = a rate in % (the dials' cycling, the
///                         fabricator, the automerger): 1 stick per
///                         20%, so 5% is 1 and 100% is 5. The panel's
///                         speed sliders SNAP to 20/40/60/80/100 (his
///                         report: two settings, one price - "segment
///                         the slider so it snaps to ram points")
///               "tap"     v = the autotapper's taps a second, 2..10 in
///                         steps of 2: a stick per 2 taps/s
///               "flag"    a switch with no speed (roll, sell): 1
///               "rebirth" the autorebirth, armed: RAM_REBIRTH
/// @param [v]
function ram_cost(_kind, _v = 0) {
	// AN OVERCLOCKED VALUE prices at its notch's multiple of the track's
	// END price (ram_oc): 1s costs 4, so 0.5s costs 12; 100% costs 5,
	// so 120% costs 8, 150% 11, 200% 15
	var _k = ram_oc_k(_kind, _v);
	if (_k >= 0) {
		var _end = (_kind == "timer") ? 4 : 5;
		return ceil(_end * ram_oc(_k).cost);
	}
	switch (_kind) {
		case "timer":   // the steps ride the range: the floor is 4, twice it 3, four times it 2
			if (_v <= RAM_TIMER_MIN)     return 4;
			if (_v <= RAM_TIMER_MIN * 2) return 3;
			if (_v <= RAM_TIMER_MIN * 4) return 2;
			return 1;
		case "speed":   return max(1, ceil(_v / 20));
		case "tap":     return max(1, ceil(_v / 2));
		case "rebirth": return RAM_REBIRTH;
	}
	return 1;
}
