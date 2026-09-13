/// @description exped_bond(a, b) -> the bond between two sprites (their
/// ids), 0..100. ONE number per pair, kept in g.bonds under "lo:hi" -
/// with the roster capped at SPRITE_CAP that is forty-five pairs at the
/// most, saved as one short string (his worry: never inflate the save).
/// exped_bond_tier reads it as strangers / mates / inseparable for the
/// diary; exped_fight_new reads it as a little hit bonus for a crew.
function exped_bond(_a, _b) {
	if (!variable_global_exists("bonds")) g.bonds = {};
	if (_a == _b) return 0;
	var _k = string(min(_a, _b)) + ":" + string(max(_a, _b));
	return g.bonds[$ _k] ?? 0;
}
