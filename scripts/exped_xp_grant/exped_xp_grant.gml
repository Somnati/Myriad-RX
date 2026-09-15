/// @description exped_xp_grant(trip, xp, why) - xp to every member still up
/// Each survivor's sheet takes it (sprite_xp_add); a level gained is a
/// truth line in the trip's log ("bibi reached level 4") and the trip's
/// hp pool grows by the new maximum's difference (sprite_pawn). why =
/// "" for a kill (quiet), or the quest's name for the home line.
function exped_xp_grant(_tr, _xp, _why) {
	if (_xp <= 0) return;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = undefined;
		for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _tr.sids[_k]) _sp = g.sprites[_i];
		if (_sp == undefined) continue;
		var _was = _tr.hpmax[_k];
		var _got = sprite_xp_add(_sp, _xp);
		if (_got > 0) {
			var _now = sprite_pawn(_sp).maxhp;
			_tr.hpmax[_k] = _now;
			_tr.hp[_k] = min(_now, _tr.hp[_k] + max(0, _now - _was));
			array_push(_tr.log, _sp.name + " reached level " + string(sprite_sheet(_sp).lv));
			if (roll_perc(40)) { var _nt = sprite_note_gen(_sp, "levelup", { lv : sprite_sheet(_sp).lv }); if (_nt != "" && sprite_note(_sp, _nt, "")) array_push(_tr.log, _sp.name + " writes: "" + _nt + """); }
		}
	}
	if (_why != "") array_push(_tr.log, "+" + string(_xp) + " xp for " + _why);
}
