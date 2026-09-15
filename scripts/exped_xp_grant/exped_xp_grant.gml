/// @description exped_xp_grant(trip, xp, why) - xp to every member of the party
/// Everyone who went takes it (his report, 2026-09-15: only one of three
/// got any - the down ones were being skipped): the up in full, the down
/// half ("they were there"). A level gained is a truth line in the log
/// ("bibi reached level 4") and the trip's hp pool grows by the new
/// maximum's difference (sprite_pawn). why = "" for a kill (quiet), or
/// the quest's name for the home line.
function exped_xp_grant(_tr, _xp, _why) {
	if (_xp <= 0) return;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _share = (_tr.hp[_k] > 0) ? _xp : round(_xp * .5);
		var _was = _tr.hpmax[_k];
		var _got = sprite_xp_add(_sp, _share);
		if (_got > 0) {
			var _now = sprite_pawn(_sp).maxhp;
			_tr.hpmax[_k] = _now;
			_tr.hp[_k] = min(_now, _tr.hp[_k] + max(0, _now - _was));
			array_push(_tr.log, _sp.name + " reached level " + string(sprite_sheet(_sp).lv));
			if (roll_perc(40)) { var _nt = sprite_note_gen(_sp, "levelup", { lv : sprite_sheet(_sp).lv }); if (_nt != "" && sprite_note(_sp, _nt, "")) array_push(_tr.log, _sp.name + " writes: \"" + _nt + "\""); }
		}
	}
	if (_why != "") array_push(_tr.log, "+" + string(_xp) + " xp each for " + _why);
}
