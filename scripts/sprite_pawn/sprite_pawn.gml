/// @description sprite_pawn(sprite, [hp]) -> a fight pawn from the sheet
/// The tech demo's combat_pawn on a sprite: real stats from the points
/// through cbt_balance (hp = pts x 3.75 + 4, eva = spd x .5, tic_spd =
/// 1 + sqrt(spd) / 2), the class garnish, the sprite's skills, a
/// half-charged mp - or the trip's mp fraction (mpf) when given. hp given =
/// carry the trip's hp in (undefined = full).
/// team / k are set by cbt_fight_new. sid links the pawn back.
function sprite_pawn(_sp, _hp = undefined, _mpf = undefined) {
	var _b  = cbt_balance();
	var _st = sprite_stats(_sp);
	var _c  = _st.cls;
	var _p  = _st.pts;
	var _maxhp = floor(_p.hp * _b.hp_per_point + _b.hp_flat_add);   // (whole hp - his ask, 2026-09-15: floored at the calc)
	var _maxmp = max(1, round(_p.mp));
	return {
		name : _sp.name, col : _sp.col, sid : _sp.id, cls : _c.key, lv : sprite_sheet(_sp).lv,
		team : 0, k : 0,
		maxhp_real : _maxhp, maxhp : _maxhp, hpmax : _maxhp,
		hp : is_undefined(_hp) ? _maxhp : clamp(_hp, 0, _maxhp),
		maxmp : _maxmp, mp : is_undefined(_mpf) ? ceil(_maxmp * _b.mp_start_frac) : clamp(round(_maxmp * _mpf), 0, _maxmp),   // (a trip carries mp between fights: the fraction it had)
		atk : _p.atk, def : _p.def, mag : _p.mag, mdef : _p.mdef, spd : _p.spd, hit : _p.hit,
		eva : _p.spd * _b.spd_to_eva,
		crit_rate : _c.crit, crit_multi : _c.cmulti, cnt : _c.cnt, erode : 1,
		magic : _c.magic,
		skills : sprite_skills(_sp),
		tic : random(.3), tic_spd : _b.tic_spd_base + sqrt(max(0, _p.spd)) / _b.tic_spd_div,
		pts_total : _st.total,
		dd : 0, dt : 0, cc : 0,
	};
}
