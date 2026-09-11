/// @description ram_cost(kind, [v]) - what one automation costs in
/// sticks, THE one price list (the panel's hover preview, the overview
/// and ram_used all read it; a price that lived in two places would
/// disagree the day one moved).
/// @param kind   "timer"   v = seconds between attempts: 1s is 4 sticks,
///                         2s 3, 3-5s 2, slower 1 - speed is what costs
///               "speed"   v = a rate in % (the dials' cycling, the
///                         fabricator, the automerger): 1 stick per
///                         20%, so 5% is 1 and 100% is 5
///               "flag"    a switch with no speed (roll, sell): 1
///               "rebirth" the autorebirth, armed: RAM_REBIRTH
/// @param [v]
function ram_cost(_kind, _v = 0) {
	switch (_kind) {
		case "timer":
			if (_v <= 1) return 4;
			if (_v <= 2) return 3;
			if (_v <= 5) return 2;
			return 1;
		case "speed":   return max(1, ceil(_v / 20));
		case "rebirth": return RAM_REBIRTH;
	}
	return 1;
}
