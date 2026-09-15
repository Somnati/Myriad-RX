/// @description exped_xp_grant(trip, xp, why) - xp to every member of the party
/// Everyone who went takes it (his report, 2026-09-15: only one of three
/// got any - the down ones were being skipped): the up in full, the down
/// half ("they were there"). A level gained is a truth line in the log
/// ("bibi reached level 4") and the trip's hp pool grows by the new
/// maximum's difference (sprite_pawn). why = "" for a kill (the line is
/// "+ 1.5 xp" - his ask, 2026-09-15: the fight's xp in the diary), or the
/// quest's name for the home line. The diary's "+ " prefix marks a
/// reward line (the panel paints them gold).
function exped_xp_grant(_tr, _xp, _why) {
	if (_xp <= 0) return;
	// (xp is kept to a tenth - a level-1 foe pays 1.0, a level-5 one 1.3)
	var _xt = (frac(_xp) == 0) ? string(round(_xp)) : string_format(_xp, 1, 1);
	if (_why == "") array_push(_tr.log, "+ " + _xt + " xp");
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _share = (_tr.hp[_k] > 0) ? _xp : round(_xp * 5) / 10;
		var _was = _tr.hpmax[_k];
		var _got = sprite_xp_add(_sp, _share);
		if (_got > 0) {
			var _now = sprite_pawn(_sp).maxhp;
			_tr.hpmax[_k] = _now;
			_tr.hp[_k] = min(_now, _tr.hp[_k] + max(0, _now - _was));
			exped_stat("levels", _got);
			array_push(_tr.log, "+ " + _sp.name + " reached level " + string(sprite_sheet(_sp).lv));
			if (roll_perc(40)) { var _nt = sprite_note_gen(_sp, "levelup", { lv : sprite_sheet(_sp).lv }); if (_nt != "" && sprite_note(_sp, _nt, "")) array_push(_tr.log, _sp.name + " writes: \"" + _nt + "\""); }
		}
	}
	if (_why != "") array_push(_tr.log, "+ " + _xt + " xp each for " + _why);
}
