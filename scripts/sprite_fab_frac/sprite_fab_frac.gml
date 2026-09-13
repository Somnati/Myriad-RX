/// @description sprite_fab_frac(s) -> the fraction of a full bar one of
/// this sprite's taps charges (tiles_fab_charge / tiles_merge_charge).
///
/// ⚖️ THE SAME SHARE AS ITS TAPS (his balance ask, 2026-09-13: "make
/// their fab output consistent with their output for tap profit
/// relative to how much tap profit i make by myself"). A sprite on the
/// tapper is worth SPRITE_STAFF x (1 + rarity) of the machine it helps
/// - that is the staff law, and a hard-working sprite's taps against a
/// hand's are about that share too. So a fab sprite working flat out
/// (a tap every SPRITE_TAP_T seconds) charges exactly SPRITE_STAFF x
/// (1 + rarity) of a bar per fab period: per tap, that share x the
/// tap interval / the bar's own seconds. A lazy personality taps less
/// and charges less; the bar getting faster (upgrades) does not
/// change the sprite's SHARE of it. SPRITE_FAB_TAP is a plain
/// multiplier on top - his knob, 1 = the law.
/// @param s  the sprite struct
function sprite_fab_frac(_s) {
	tiles_init();
	var _bar_s = max(1, g.tiles.fab_t / 60);   // the bar's seconds at the current rate
	return SPRITE_STAFF * (1 + (_s[$ "rar"] ?? 0)) * SPRITE_TAP_T / _bar_s * SPRITE_FAB_TAP;
}
