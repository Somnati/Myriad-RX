/// @description exped_fork_mods(trip, fork) -> [{ name, v }] the party's modifiers on the fork's check (exped_check)
/// What the crew brings to the roll, read fresh off the sheets: a RANGER
/// knows the country (+3 through the wild, +2 slipping past a foe), a
/// ROGUE the footing on a pass and the way round a foe (+2 / +3), a
/// LANTERN or torch worn in the dark or the fog (+2), HIDE, a cloak or
/// a robe in the snow (+2 - the cold's own families), and the best LUCK
/// in the party (half of it, three at most)
function exped_fork_mods(_tr, _fk) {
	var _mods = [];
	var _rng = false, _rog = false, _luck = 0, _light = false, _warm = false, _known = false;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _st = sprite_stats(_sp);
		if (_fk.kind == "shortcut" && sprite_note_has(_sp, "road:" + _fk.land)) _known = true;   // (a note on this land: the party knows a way - q260)
		if (_st.cls.key == "ranger") _rng = true;
		if (_st.cls.key == "rogue") _rog = true;
		_luck = max(_luck, sprite_luck(_sp));
		for (var _w = 0; _w < array_length(_st.worn); _w++) {
			var _fm = _st.worn[_w].fam;
			if (_fm == "lantern" || _fm == "torch") _light = true;
			if (_fm == "hide" || _fm == "cloak" || _fm == "robe") _warm = true;
		}
	}
	if (_fk.kind == "shortcut") {
		if (_rng) array_push(_mods, { name : "ranger", v : 3 });
		if (_known) array_push(_mods, { name : "a note", v : 2 });
		if (_rog && (_fk.land == "mountains" || _fk.land == "hills" || _fk.land == "forest")) array_push(_mods, { name : "rogue", v : 2 });
		if (_light && (_fk.night || _fk.wx == "fog")) array_push(_mods, { name : "light", v : 2 });
		if (_warm && (_fk.wx == "snow" || _fk.land == "tundra")) array_push(_mods, { name : "warm", v : 2 });
	} else {
		if (_rog) array_push(_mods, { name : "rogue", v : 3 });
		if (_rng) array_push(_mods, { name : "ranger", v : 2 });
	}
	if (_luck >= 2) array_push(_mods, { name : "luck", v : min(3, floor(_luck / 2)) });
	// THE LEADER'S MOOD on the die (q261): shaken, grieving or tired -1; cocky or eager +1
	var _lead = undefined;
	for (var _lk = 0; _lk < array_length(_tr.sids); _lk++) if (_tr.hp[_lk] > 0) { _lead = exped_sprite(_tr.sids[_lk]); break; }
	var _mw = is_undefined(_lead) ? "" : mood_word(_lead).key;
	if (_mw == "shaken" || _mw == "grieving" || _mw == "tired") array_push(_mods, { name : _mw, v : -1 });
	else if (_mw == "cocky" || _mw == "eager") array_push(_mods, { name : _mw, v : 1 });
	return _mods;
}
