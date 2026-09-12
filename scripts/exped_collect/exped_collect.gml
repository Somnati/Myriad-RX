/// @description exped_collect(x, y) - the haul card is taken: every
/// find lands where it belongs. Credits fly to the purse (credit_drop),
/// a sprite spawns asleep, an offer rolls into a free slot, a charm is
/// a luck point, a chart raises the board's depth, materials pile up
/// by family. The crew comes home (a routed one naps).
/// @param x   where the motes leave from
/// @param y
function exped_collect(_x, _y) {
	exped_init();
	var _e = g.exped;
	if (is_undefined(_e.haul)) return;
	var _h = _e.haul;
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		switch (_l.kind) {
			case "credits": credit_drop(_x, _y, _l.n, 6); break;
			case "sprite": {
				var _sp = sprite_spawn("tap");
				_sp.asleep = true;
				_sp.found  = _h.dest.name;
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
	// the crew is home
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _sp = g.sprites[_i];
		if (_sp.id != _h.sid) continue;
		_sp.trip = false;
		if (_h.routed) { _sp.asleep = true; _sp.hurt = EXPED_NAP; }
	}
	_e.haul = undefined;
	exped_board_roll();
	save_mark_dirty();
}
