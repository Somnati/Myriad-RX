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
	var _stn = exped_stance(_tr);   // (the stance moves the threshold: cautious earlier, greedy later - 2026-09-16)
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
			// THE PHOENIX DRAUGHT (2026-09-17): the totem's lesser cousin - up again at three tenths
			for (var _jp = 0; _jp < array_length(_sh.inv); _jp++) {
				var _tp2 = _sh.inv[_jp];
				if ((_tp2[$ "slot"] ?? "") != "use" || _tp2.kind != "phoenix") continue;
				array_delete(_sh.inv, _jp, 1);
				_pw.hp = max(1, ceil(_pw.maxhp * .3));
				var _pl2 = _sp.name + "'s phoenix draught catches - " + _sp.name + " is up again";
				if (is_struct(_f)) { cbt_log(_f, _pl2); cbt_film(_f, undefined, 0, _pl2); }
				array_push(_tr.log, _pl2 + choose(". the bottle is ash", ". warm all over", ". it burned going down"));
				save_mark_dirty();
				return true;
			}
			continue;
		}
		if (_pn == "dreamy" && roll_perc(60)) continue;   // (forgot the pocket)
		// THE ANTIDOTE (2026-09-17): in a fight, poisoned, slowed or marked - the bottle, if it carries one
		if (is_struct(_pw) && is_struct(_pw[$ "ail"]) && (_pw.ail.poison > 0 || _pw.ail.slow > 0 || _pw.ail.leech > 0)) {
			for (var _ja = 0; _ja < array_length(_sh.inv); _ja++) {
				var _ita = _sh.inv[_ja];
				if ((_ita[$ "slot"] ?? "") != "use" || _ita.kind != "antidote") continue;
				array_delete(_sh.inv, _ja, 1);
				_pw.ail.poison = 0; _pw.ail.slow = 0; _pw.ail.leech = 0; _pw.leecher = undefined;
				var _al = _sp.name + " drank the antidote" + choose(". the venom lets go", ". clear-headed again", ". the mark fades");
				if (is_struct(_f)) { cbt_log(_f, _al); cbt_film(_f, undefined, 0, _al); }
				array_push(_tr.log, _al); _drank = true; save_mark_dirty();
				break;
			}
		}
		var _thv = clamp(_thr(_pn) + _stn.drink, .1, .9);
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
			// A BOTTLE OF SOMETHING (2026-09-17): no red one - the mystery potion, if there is one. usually good
			var _myst = false, _mroll = -1;
			if (_at < 0) for (var _jm = 0; _jm < array_length(_sh.inv); _jm++) { var _itm = _sh.inv[_jm]; if ((_itm[$ "slot"] ?? "") == "use" && _itm.kind == "mystery") { _at = _jm; _myst = true; break; } }
			if (_at >= 0) {
				var _pot = _sh.inv[_at];
				array_delete(_sh.inv, _at, 1);
				var _mfrac = (_pot.size >= 2) ? .8 : .4;
				if (_myst) { _mroll = random(100); _mfrac = (_mroll < 55) ? .5 : ((_mroll < 80) ? .25 : 0); }
				var _heal = _hpm * _mfrac * max(.1, 1 + (sprite_ab(_sp).potion + exped_party_ab(_tr).aura_potion) / 100);   // (gourmet, the quartermaster's aura, picky - 2026-09-17)
				var _newhp = min(_hpm, _hpn + _heal);
				if (is_struct(_pw)) _pw.hp = _newhp; else _tr.hp[_k] = round(_newhp * 10) / 10;
				var _dl = _sp.name + " drank the " + _pot.name + (_myst ? ((_mroll < 55) ? ". it was a red one, more or less" : ((_mroll < 80) ? ". something happened. good, probably" : ". it tasted of tuesday. nothing happened")) : choose(". it tasted of red", ". better", ". most of it went in", " in one", ". the colour came back", ". it fizzed"));
				if (_myst && _mroll >= 55 && _mroll < 80 && is_struct(_f) && is_struct(_pw)) cbt_status(_f, _pw, _pw, choose("buf_atk", "buf_def", "buf_hit", "haste"));   // (the good, probably)
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
				_pw.mp = min(_pw.maxmp, _pw.mp + ceil(((_it2.size >= 2) ? _pw.maxmp : ceil(_pw.maxmp * .5)) * max(.1, 1 + (sprite_ab(_sp).potion + exped_party_ab(_tr).aura_potion) / 100)));   // (gourmet, the quartermaster's aura, picky - 2026-09-17)
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
