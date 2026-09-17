/// @description upgrade_tier_add(rarity, bought, cap) - what the NEXT
/// tier of an upgrade is worth, as a multiple of its rolled base value.
/// @param rarity  the slot's rung
/// @param bought  tiers already bought (0 = the first tier is next)
/// @param cap     how deep the offer goes
///
/// MYRIAD DE'S update_upgrade, VERBATIM (his ask, 2026-09-17: "each
/// tier is supposed to increase the next tiers output/cost with the
/// final tier having a much higher jump...check DE for this"):
///
///     _add = 1 + k x bought                     k = .2 common ... .6 elite+
///     if the next tier is the LAST and cap > 1:
///         _add += (c / 3) x cap                 c = .5 common ... 3 divine+
///     _add *= rarity multiplier                 1 / 2.5 / 5 / 10 / 15 / 20 / 25
///
/// so a common at base 5 pays 5, 6, then 9.5 on its third and last
/// tier; an uncommon (x2.5) 12.5, 15.6, 31.25. The ramp is per RARITY,
/// which is what the flat .15 ramp here missed. DE's `_add_boost` (the
/// finisher abilities) and `_add2` (the upgrade LEVEL meta, an xp
/// ladder RX skipped) are left out - both are 1 without them.
function upgrade_tier_add(_rar, _bought, _cap) {
	var _r = clamp(floor(_rar), 0, UPG_RARITY_N - 1);
	// fourteen rungs (2026-09-17): DE's per-rarity ramp and jump, stretched
	var _k = [.18, .2, .25, .3, .4, .45, .5, .55, .6, .6, .6, .6, .6, .6];
	var _c = [.4, .5, 1, 1.2, 1.5, 2, 2.2, 2.5, 2.7, 3, 3, 3, 3, 3];
	var _add = 1 + _k[_r] * max(0, _bought);
	if (_cap > 1 && _bought == _cap - 1) _add += (_c[_r] / 3) * _cap;
	return _add * upgrade_rarity_mult(_r);
}
