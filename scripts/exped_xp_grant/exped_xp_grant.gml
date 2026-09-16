/// @description exped_xp_grant(trip, xp, why) - xp SHARED across the party
/// xp is the POOL (the pack's, the quest's); it is divided among everyone
/// who went (his call, 2026-09-15: "for balance reasons xp earned should
/// be divided across all party members") - a member who is up holds a
/// full share, one who is down half a share ("they were there"); a lone
/// sprite takes the lot. A level gained is a truth line in the log
/// ("bibi reached level 4") and the trip's hp pool grows by the new
/// maximum's difference (sprite_pawn). why = "" for a kill (the line is
/// "+ 1.5 xp" - his ask, 2026-09-15: the fight's xp in the diary), or the
/// quest's name for the home line. The diary's "+ " prefix marks a
/// reward line (the panel paints them gold).
function exped_xp_grant(_tr, _xp, _why) {
	if (_xp <= 0) return;
	exped_tally(_tr, "xp", _xp);   // (the completion screen's "xp earned", 2026-09-16)
	// (xp is kept to a tenth - a level-1 foe pays 1.0, a level-5 one 1.3)
	var _xt = (frac(_xp) == 0) ? string(round(_xp)) : string_format(_xp, 1, 1);
	// the shares: 1 up, .5 down; the pool over their sum
	var _shares = 0;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) if (!is_undefined(exped_sprite(_tr.sids[_k]))) _shares += (_tr.hp[_k] > 0) ? 1 : .5;
	if (_shares <= 0) return;
	var _each = _xp / _shares;
	var _et = (frac(_each) == 0) ? string(round(_each)) : string_format(_each, 1, 1);
	var _split = (array_length(_tr.sids) > 1) ? (" (" + _et + " each)") : "";
	if (_why == "") array_push(_tr.log, "+ " + _xt + " xp" + _split);
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _share = round(_each * ((_tr.hp[_k] > 0) ? 1 : .5) * 10) / 10;
		var _was = _tr.hpmax[_k];
		var _got = sprite_xp_add(_sp, _share);
		if (_got > 0) {
			var _now = sprite_pawn(_sp).maxhp;
			_tr.hpmax[_k] = _now;
			_tr.hp[_k] = min(_now, _tr.hp[_k] + max(0, _now - _was));
			exped_stat("levels", _got);
			array_push(_tr.log, "+ " + _sp.name + " reached level " + string(sprite_sheet(_sp).lv));
			exped_say(_tr, "levelup", { sid : _sp.id }, .75);   // (the one who levelled speaks - 2026-09-15)
			if (roll_perc(40)) { var _lt = sprite_skill_learn(_sp); if (_lt != "") { array_push(_tr.log, "+ " + _lt); exped_stat("skills"); exped_say(_tr, "skill", { sid : _sp.id }, .6); } }
			if (roll_perc(40)) { var _nt = sprite_note_gen(_sp, "levelup", { lv : sprite_sheet(_sp).lv }); if (_nt != "" && sprite_note(_sp, _nt, "")) array_push(_tr.log, _sp.name + " writes: \"" + _nt + "\""); }
		}
	}
	if (_why != "") array_push(_tr.log, "+ " + _xt + " xp for " + _why + _split);
}
