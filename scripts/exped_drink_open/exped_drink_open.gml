/// @description exped_drink_open(trip, fight) - THE POCKET AT THE DOOR (2026-09-17):
/// walking into a fight each member up looks at what it carries - against
/// a titled foe or a pack of three, a potion of strength / stone skin /
/// haste / clarity (the first it has); under six tenths of hp, a potion
/// of regeneration; against a foe of an element, that element's ward
/// (+30 res for the fight); against a titled foe, a potion of growth
/// (twice the xp from it). One of each, and the diary says so.
function exped_drink_open(_tr, _f) {
	var _boss = false, _big = (array_length(_f.foes) >= 3), _els = [];
	for (var _j = 0; _j < array_length(_f.foes); _j++) { var _fo = _f.foes[_j]; if (_fo[$ "boss"] ?? false) _boss = true; var _fe = _fo[$ "elem"] ?? ""; if (_fe != "" && !array_contains(_els, _fe)) array_push(_els, _fe); }
	var _b = cbt_balance();
	static _take = function(_sh, _kind) { for (var _j = 0; _j < array_length(_sh.inv); _j++) { var _it = _sh.inv[_j]; if ((_it[$ "slot"] ?? "") == "use" && _it.kind == _kind) { array_delete(_sh.inv, _j, 1); return _it; } } return undefined; };
	for (var _p = 0; _p < array_length(_f.party); _p++) {
		var _pw = _f.party[_p];
		if (_pw.hp <= 0 || !is_real(_pw[$ "mi"])) continue;
		var _sp = exped_sprite(_tr.sids[_pw.mi]);
		if (is_undefined(_sp)) continue;
		var _sh = sprite_sheet(_sp), _drank = [];
		if (_boss || _big) {
			var _bk = ["strength", "stoneskin", "haste", "clarity"], _bs = ["buf_atk", "buf_def", "haste", "buf_hit"];
			for (var _i = 0; _i < 4; _i++) { var _it = _take(_sh, _bk[_i]); if (!is_undefined(_it)) { cbt_status(_f, _pw, _pw, _bs[_i]); array_push(_drank, _it.name); break; } }
		}
		if (_pw.hp < _pw.maxhp * .6) { var _itr = _take(_sh, "regen"); if (!is_undefined(_itr)) { cbt_status(_f, _pw, _pw, "regen"); array_push(_drank, _itr.name); } }
		for (var _e = 0; _e < array_length(_els); _e++) {
			var _wk = (_els[_e] == "fire") ? "fireward" : ((_els[_e] == "water") ? "waterward" : ((_els[_e] == "nature") ? "thornward" : ""));
			if (_wk == "") continue;
			var _itw = _take(_sh, _wk);
			if (!is_undefined(_itw)) { if (is_struct(_pw[$ "res"])) _pw.res[$ _els[_e]] = clamp((_pw.res[$ _els[_e]] ?? 0) + 30, _b.res_min, _b.res_max); array_push(_drank, _itw.name); }
		}
		if (_boss) { var _itg = _take(_sh, "growth"); if (!is_undefined(_itg)) { _tr.xp_pot = true; array_push(_drank, _itg.name); } }
		if (array_length(_drank) > 0) {
			var _dl = _sp.name + " drank the " + exped_crew_txt(_drank) + " at the door" + choose(". ready", ". just in case", ". in one", ". then looked braver");
			cbt_log(_f, _dl); cbt_film(_f, undefined, 0, _dl);
			array_push(_tr.log, _dl);
			save_mark_dirty();
		}
	}
}
