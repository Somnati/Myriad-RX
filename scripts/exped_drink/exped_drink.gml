/// @description exped_drink(trip, [pawn], [fight], [fallen]) - THE CREW DRINKS WHAT IT CARRIES (his ask, 2026-09-16), by temperament
/// Without a pawn: on the road, every member up - a red potion when low.
/// With a pawn (a fight, at the start of its turn - cbt_fight_turn): a free
/// action - a red potion when low, a blue one when the mp is short of a
/// skill. WHEN is the temperament's: the nervous drink at half, the brave
/// at a quarter, the greedy at the last moment, the dreamy forget they
/// have one more often than not; everyone else at a third.
/// fallen = true (cbt_hit, the pawn just went down): THE TOTEM OF DON'T
/// DIE - if the pocket holds one it cracks and the sprite stands up at
/// half hp. Returns true when something was drunk (or the totem cracked).
function exped_drink(_tr, _pw = undefined, _f = undefined, _fallen = false) {
	static _thr = function(_pn) { switch (_pn) { case "nervous": return .5; case "brave": return .25; case "greedy": return .15; default: return .35; } };
	var _drank = false;
	var _ks = [];
	if (is_struct(_pw)) { if (is_real(_pw[$ "mi"])) array_push(_ks, _pw.mi); }
	else for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) array_push(_ks, _k);
	var _pl = sprite_personalities();
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _k = _ks[_i];
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _sh = sprite_sheet(_sp);
		var _pn = _pl[clamp(_sp[$ "pers"] ?? 0, 0, array_length(_pl) - 1)].name;
		// THE TOTEM
		if (_fallen) {
			for (var _j = 0; _j < array_length(_sh.inv); _j++) {
				var _tt = _sh.inv[_j];
				if ((_tt[$ "slot"] ?? "") != "use" || _tt.kind != "totem") continue;
				array_delete(_sh.inv, _j, 1);
				var _back = max(1, ceil(_pw.maxhp * .5));
				_pw.hp = _back;
				var _tl = _sp.name + "'s totem cracks - " + _sp.name + " is up again";
				if (is_struct(_f)) { cbt_log(_f, _tl); cbt_film(_f, undefined, 0, _tl); }
				array_push(_tr.log, _tl + choose(". it was a good totem", ". the totem is dust", ". nobody saw the totem again"));
				save_mark_dirty();
				return true;
			}
			continue;
		}
		if (_pn == "dreamy" && roll_perc(60)) continue;   // (forgot the pocket)
		var _thv = _thr(_pn);
		var _hpn = is_struct(_pw) ? _pw.hp : _tr.hp[_k], _hpm = is_struct(_pw) ? _pw.maxhp : _tr.hpmax[_k];
		if (_hpn > 0 && _hpn / max(1, _hpm) < _thv) {
			// the red one: a big one when it is bad, a small one otherwise; the first that fits
			var _want = (_hpn / max(1, _hpm) < _thv * .5) ? 2 : 1, _at = -1, _alt = -1;
			for (var _j = 0; _j < array_length(_sh.inv); _j++) {
				var _it = _sh.inv[_j];
				if ((_it[$ "slot"] ?? "") != "use" || _it.kind != "hp") continue;
				if (_it.size == _want && _at < 0) _at = _j; else if (_alt < 0) _alt = _j;
			}
			if (_at < 0) _at = _alt;
			if (_at >= 0) {
				var _pot = _sh.inv[_at];
				array_delete(_sh.inv, _at, 1);
				var _heal = _hpm * ((_pot.size >= 2) ? .8 : .4);
				var _newhp = min(_hpm, _hpn + _heal);
				if (is_struct(_pw)) _pw.hp = _newhp; else _tr.hp[_k] = round(_newhp * 10) / 10;
				var _dl = _sp.name + " drank the " + _pot.name + choose(". it tasted of red", ". better", ". most of it went in", " in one", ". the colour came back", ". it fizzed");
				if (is_struct(_f)) { cbt_log(_f, _dl); cbt_film(_f, undefined, 0, _dl); }
				array_push(_tr.log, _dl);
				_drank = true;
				save_mark_dirty();
			}
		}
		// the blue one, in a fight, when the mp is short of the skill
		if (is_struct(_pw) && _pw.maxmp > 0 && _pw.mp < 3) {
			for (var _j = 0; _j < array_length(_sh.inv); _j++) {
				var _it2 = _sh.inv[_j];
				if ((_it2[$ "slot"] ?? "") != "use" || _it2.kind != "mp") continue;
				array_delete(_sh.inv, _j, 1);
				_pw.mp = min(_pw.maxmp, _pw.mp + ((_it2.size >= 2) ? _pw.maxmp : ceil(_pw.maxmp * .5)));
				var _bl = _sp.name + " drank the " + _it2.name + choose(". blue, then clear", ". cold", ". the hum came back", ". it tastes of a window");
				cbt_log(_f, _bl); cbt_film(_f, undefined, 0, _bl);
				array_push(_tr.log, _bl);
				_drank = true;
				save_mark_dirty();
				break;
			}
		}
	}
	return _drank;
}
