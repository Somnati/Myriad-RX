/// @description exped_fight_new(trip) -> a fight: the crew that is still
/// up against one foe of the world's tier. A member's numbers come from
/// its personality's pace; a crew of two or three also carries a little
/// of its BONDS into the hit chance (exped_bond, up to +10). The foe's
/// hp scales with the crew so three do not shred what one would fight.
/// exped_fight_turn plays it; the panel's combat window shows it.
function exped_fight_new(_tr) {
	var _d  = _tr.dest;
	var _pl = sprite_personalities();
	var _party = [];
	var _n = array_length(_tr.sids);
	// the crew's mean bond, for the little bonus
	var _bsum = 0, _bn = 0;
	for (var _a = 0; _a < _n; _a++) for (var _b = _a + 1; _b < _n; _b++) { _bsum += exped_bond(_tr.sids[_a], _tr.sids[_b]); _bn++; }
	var _bonus = (_bn > 0) ? min(10, (_bsum / _bn) / 10) : 0;
	for (var _k = 0; _k < _n; _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = undefined;
		for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _tr.sids[_k]) _sp = g.sprites[_i];
		var _pace = 1;
		if (_sp != undefined) _pace = _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].pace;
		array_push(_party, { k : _k, sid : _tr.sids[_k], name : _tr.names[_k], col : _tr.cols[_k],
		                     hp : _tr.hp[_k], hpmax : _tr.hpmax[_k],
		                     hit : clamp(60 + 15 * _pace + _bonus, 40, 95), init : 5 + 3 * _pace, dmg : 2 });
	}
	var _foes = ["a scrap crawler", "a hollow warden", "a shard mite", "a dust wraith", "a rust beetle", "a lantern moth"];
	var _up = max(1, array_length(_party));
	return {
		party : _party,
		b : { name : _foes[irandom(array_length(_foes) - 1)],
		      hp : round((5 + 3 * _d.tier) * (1 + .5 * (_up - 1))), hpmax : round((5 + 3 * _d.tier) * (1 + .5 * (_up - 1))),
		      hit : clamp(45 + 5 * _d.tier, 30, 90), init : 4 + _d.tier, dmg : 1 + floor(_d.tier / 2) },
		turn : 0, over : false, won : false, log : [],
		t : 0,              // the clock toward the next turn (EXPED_FIGHT_T)
		last : undefined,   // { side : "a" (a member, k) / "b" (the foe), dmg, at : current_time } - the window's flash
	};
}
