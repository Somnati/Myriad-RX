/// @description syz_hook() -> { flux, life, rate, tokens, cycles, grand, best } THE TIE-IN (q315), unwired by his ask. Ideas kept: flux sold for profit at the tap room's rate; a grand conjunction as a burst (upgrades' bursts) or a wheel spin; the cycles' periods driven by the dials' cycle times (a dial IS a cycle - the conjunction of dials); tokens as a rebirth garnish
function syz_hook() {
	var _s = syz_init();
	return { flux : _s.flux, life : _s.life, rate : _s.rate, tokens : _s.tokens, cycles : array_length(_s.cycles), grand : _s.grand, best : _s.best };
}
