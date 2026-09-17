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
	// THE GARNISH off the gear's quirks (the proc-gear pass, 2026-09-15): crit, counter, wear, the mp a fight opens with
	var _gcrit = 0, _gcnt = 0, _gerode = 1, _gmp0 = 0;
	for (var _w = 0; _w < array_length(_st.worn); _w++) { var _wi = _st.worn[_w]; _gcrit += _wi[$ "crit"] ?? 0; _gcnt += _wi[$ "cnt"] ?? 0; _gerode *= _wi[$ "erode"] ?? 1; _gmp0 += _wi[$ "mp0"] ?? 0; }
	_gerode = max(.25, _gerode);
	// THE WEAPON'S ELEMENT (2026-09-17): a burning / soaked / thorned main hand
	// puts its element on every basic attack; the off hand only if the main has none
	var _welem = "";
	for (var _w = 0; _w < array_length(_st.worn); _w++) { var _wi2 = _st.worn[_w]; if ((_wi2[$ "elem"] ?? "") != "" && (_wi2.slot == "w1" || (_welem == "" && _wi2.slot == "w2"))) _welem = _wi2.elem; }
	return {
		name : _sp.name, col : _sp.col, sid : _sp.id, cls : _c.key, lv : sprite_sheet(_sp).lv,
		team : 0, k : 0,
		maxhp_real : _maxhp, maxhp : _maxhp, hpmax : _maxhp,
		hp : is_undefined(_hp) ? _maxhp : clamp(_hp, 0, _maxhp),
		maxmp : _maxmp, mp : is_undefined(_mpf) ? ceil(_maxmp * min(1, _b.mp_start_frac + _gmp0)) : clamp(round(_maxmp * min(1, _mpf + _gmp0)), 0, _maxmp),   // (a trip carries mp between fights: the fraction it had; an eager item adds to it)
		atk : _p.atk, def : _p.def, mag : _p.mag, mdef : _p.mdef, spd : _p.spd, hit : _p.hit,
		eva : _p.spd * _b.spd_to_eva,
		crit_rate : _c.crit + _gcrit + sprite_luck(_sp) * .5, crit_multi : _c.cmulti, cnt : _c.cnt + _gcnt, erode : _gerode,   // (luck: half a point of crit a point, 2026-09-16)
		magic : _c.magic, luck : sprite_luck(_sp),
		skills : sprite_skills(_sp),
		tic : random(.3), tic_spd : _b.tic_spd_base + sqrt(max(0, _p.spd)) / _b.tic_spd_div,
		pts_total : _st.total,
		dd : 0, dt : 0, cc : 0,
		// the elements pass (2026-09-17): the table, the weapon's element, no
		// bite of its own, and the fight-long clocks
		res : sprite_res(_sp), elem : _welem, school : "", ail_k : "", tags : [],
		ail : { poison : 0, slow : 0, leech : 0 }, bf : { atk : 0, def : 0, hit : 0, spd : 0 }, nf : { atk : 0, def : 0, hit : 0 }, regen : 0, leecher : undefined,
	};
}
