/// @description exped_fight_new(trip) -> a fight (cbt_fight_new)
/// THE CREW THAT IS STILL UP, as pawns off their sheets (sprite_pawn:
/// class, level, gear, skills - the tech demo's engine, his call
/// 2026-09-14), against AS MANY FOES AS THEY ARE, of the world's level
/// (foe_gen: the world's level or one above, rolled from the world, the
/// trip and the room so a save that reloads mid-fight meets the same pack). A crew of
/// two or three carries a little of its BONDS into every member's hit
/// (exped_bond, up to +10). The struct is what the combat window reads;
/// each party pawn remembers its trip index (mi) for the hp write-back.
function exped_fight_new(_tr) {
	var _d  = _tr.dest;
	var _party = [];
	var _n = array_length(_tr.sids);
	var _bsum = 0, _bn = 0;
	for (var _a = 0; _a < _n; _a++) for (var _b = _a + 1; _b < _n; _b++) { _bsum += exped_bond(_tr.sids[_a], _tr.sids[_b]); _bn++; }
	var _bonus = (_bn > 0) ? min(10, (_bsum / _bn) / 10) : 0;
	for (var _k = 0; _k < _n; _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = undefined;
		for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _tr.sids[_k]) _sp = g.sprites[_i];
		if (_sp == undefined) continue;
		var _pw = sprite_pawn(_sp, _tr.hp[_k]);
		_pw.hit += _bonus;
		_pw.mi = _k;
		_pw.studied = sprite_notes_kinds(_sp);   // the notepad: foe kinds it has written up (cbt_hit: +SPRITE_NOTE_HIT)
		array_push(_party, _pw);
	}
	// A CREW OF N MEETS N FOES (the twin: three on one was a formality) -
	// each rolled from the world, the trip, the room and its place, so a
	// save reloading mid-fight meets the same pack; the kill pays the
	// pack's stat total to every survivor (his law)
	var _foes = [], _xp = 0;
	var _nf = max(1, array_length(_party));
	for (var _j = 0; _j < _nf; _j++) {
		var _seed = (_d.seed ^ (_tr.id * 7919) ^ ((_tr.room_i + 1) * 104729) ^ (_j * 15485863)) & $7fffffff;
		var _foe = foe_gen(exped_world_lv(_d) + ((_seed mod 3 == 0) ? 1 : 0), _seed);
		array_push(_foes, _foe);
		_xp += foe_xp(_foe);
	}
	var _f = cbt_fight_new(_party, _foes);
	_f.xp = _xp;
	return _f;
}
