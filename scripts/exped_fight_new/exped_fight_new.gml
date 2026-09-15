/// @description exped_fight_new(trip, [kind], [count], [lvadd]) -> a fight (cbt_fight_new)
/// THE CREW THAT IS STILL UP, as pawns off their sheets (sprite_pawn:
/// class, level, gear, skills - the tech demo's engine, his call
/// 2026-09-14), against A PACK of the region's level: one to three
/// (count -1; his call: never the party's size) or a given number, of a given kind ("" = the
/// roster's roll), lvadd levels above the world (foe_gen). A crew of two
/// or three carries a little of its BONDS into every member's hit
/// (exped_bond, up to +10), and the notepad's studied kinds. The struct
/// is what the combat window reads; each party pawn remembers its trip
/// index (mi) for the hp write-back. The pack's xp is the kill's pay.
function exped_fight_new(_tr, _kind = "", _count = -1, _lvadd = 0) {
	var _d  = _tr.dest;
	var _party = [];
	var _n = array_length(_tr.sids);
	var _bsum = 0, _bn = 0;
	for (var _a = 0; _a < _n; _a++) for (var _b = _a + 1; _b < _n; _b++) { _bsum += exped_bond(_tr.sids[_a], _tr.sids[_b]); _bn++; }
	var _bonus = (_bn > 0) ? min(10, (_bsum / _bn) / 10) : 0;
	for (var _k = 0; _k < _n; _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _pw = sprite_pawn(_sp, _tr.hp[_k], (is_array(_tr[$ "mp"]) && _k < array_length(_tr.mp)) ? _tr.mp[_k] : undefined);
		_pw.hit += _bonus;
		_pw.mi = _k;
		_pw.studied = sprite_notes_kinds(_sp);
		array_push(_party, _pw);
	}
	var _foes = [], _xp = 0;
	// THE PACK (his call, 2026-09-15: "not based off my party size"): a
	// count asked for, or one to three - one 35%, two 40%, three 25%
	var _nf = _count;
	if (_nf <= 0) { var _pr = random(100); _nf = (_pr < EXPED_PACK_W1) ? 1 : ((_pr < EXPED_PACK_W1 + EXPED_PACK_W2) ? 2 : 3); }
	_tr.fights = (_tr[$ "fights"] ?? 0) + 1;
	for (var _j = 0; _j < _nf; _j++) {
		var _seed = (_d.seed ^ (_tr.id * 7919) ^ (_tr.fights * 104729) ^ (_j * 15485863)) & $7fffffff;
		var _foe = foe_gen(exped_trip_lv(_tr) + _lvadd + ((_seed mod 3 == 0) ? 1 : 0), _seed, _kind);
		array_push(_foes, _foe);
		_xp += foe_xp(_foe);
	}
	var _f = cbt_fight_new(_party, _foes);
	_f.xp = _xp;
	return _f;
}
