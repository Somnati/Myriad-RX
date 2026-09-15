/// @description exped_collect(haul index, x, y, [choice]) -> "ok", or
/// "recruit" when the haul carries a found sprite and the roster is full
/// (SPRITE_CAP) - THE RECRUIT MOMENT (his call: never an inventory):
/// the panel asks, and calls again with choice "swap:<sid>" (that sprite
/// retires, exped_retire, and the new one takes its place) or "letgo"
/// (the new one leaves a charm and goes). Everything else in the haul
/// pays out as always; the crew comes off the trip (a routed crew naps).
function exped_collect(_hi, _x, _y, _choice = "") {
	exped_init();
	var _e = g.exped;
	if (_hi < 0 || _hi >= array_length(_e.hauls)) return "none";
	var _h = _e.hauls[_hi];
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	if (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP && _choice == "") return "recruit";
	// the crew comes home first (a swap may retire one of them)
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _sp = g.sprites[_i];
		if (!array_contains(_h.sids, _sp.id)) continue;
		_sp.trip = false;
		if (_h.routed) { _sp.asleep = true; _sp.hurt = EXPED_NAP; }
		// HOME SHORT (his ask, 2026-09-15): the hp and mp they came back with
		// ride the sprite; short of either, it sleeps until whole (resting -
		// sprites_tick's climb wakes it; the offline nap is another rule)
		var _k = array_get_index(_h.sids, _sp.id);
		var _hhp = _h[$ "hp"] ?? [], _hhm = _h[$ "hpmax"] ?? [], _hmp = _h[$ "mp"] ?? [];
		_sp.hpf = (_k >= 0 && _k < array_length(_hhp)) ? clamp(_hhp[_k] / max(1, (_k < array_length(_hhm)) ? _hhm[_k] : 1), 0, 1) : 1;
		_sp.mpf = (_k >= 0 && _k < array_length(_hmp)) ? clamp(_hmp[_k], 0, 1) : 1;
		if (_sp.hpf <= 0) _sp.hpf = .05;   // (down at the end: it comes home at a sliver)
		if (_sp.hpf < 1 || _sp.mpf < 1) { _sp.asleep = true; _sp.resting = true; }
	}
	var _swapped = false;
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		switch (_l.kind) {
			case "credits": credit_drop(_x, _y, _l.n, 6); exped_stat("credits", _l.n); break;
			case "sprite": {
				if (array_length(g.sprites) >= SPRITE_CAP) {
					if (string_pos("swap:", _choice) == 1 && !_swapped) {
						var _gone = exped_retire(real(string_delete(_choice, 1, 5)));
						_swapped = true;
						if (_gone != "") array_push(_h.log, "~ " + _gone + " has gone to live somewhere quieter. the others waved. one of them cried, and will not say which.");
					}
				}
				if (array_length(g.sprites) < SPRITE_CAP) {
					var _sp = sprite_spawn("tap");
					exped_stat("recruits");
					_sp.asleep = true;
					_sp.found  = _h.dest.name;
					if (is_string(_l[$ "name"])) _sp.name = _l.name;   // (met on the road: it keeps the name it gave)
				} else {
					_e.charms += 1;
					array_push(_h.log, "~ the new one left a charm and went back into the dark. politely.");
				}
				break;
			}
			case "offer": {
				var _slot = -1;
				for (var _k = 0; _k < upgrade_slots(); _k++) if (!is_struct(g.upg.slot[_k])) { _slot = _k; break; }
				if (_slot >= 0) upgrade_roll(_slot);
				break;
			}
			case "charm": _e.charms += 1; break;
			case "chart": _e.depth = min(_e.depth + 1, 8); break;
			case "mats": {
				var _key = _l.fam + " t" + string(_l.tier);
				_e.mats[$ _key] = (_e.mats[$ _key] ?? 0) + _l.n;
				break;
			}
		}
	}
	array_delete(_e.hauls, _hi, 1);
	exped_stat("hauls");
	exped_board_roll();
	save_mark_dirty();
	return "ok";
}
