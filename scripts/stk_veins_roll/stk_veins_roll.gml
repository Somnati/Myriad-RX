/// @description stk_veins_roll(s) - VEINS (q317): each run, one sink a layer carries a vein (per x2) - rolled off the turn count, seeded (always two rolls a layer; the second is honoured only with rich veins, so the perk never reshuffles a run)
function stk_veins_roll(_s) {
	var _old = random_get_seed();
	random_set_seed((74123 ^ (_s.turns * 2654435761)) & $7fffffff);
	for (var _l = 0; _l < array_length(_s.layers); _l++) {
		var _ly = _s.layers[_l];
		_ly.vein = irandom(5);
		_ly.vein2 = (_ly.vein + 1 + irandom(4)) mod 6;
	}
	rng_release(_old);
}
