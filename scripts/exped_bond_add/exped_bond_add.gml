/// @description exped_bond_add(a, b, n) - move a pair's bond by n,
/// clamped 0..100 (exped_tick's home: a trip together, fights won
/// together; a rout costs). Marks the save.
function exped_bond_add(_a, _b, _n) {
	if (!variable_global_exists("bonds")) g.bonds = {};
	if (_a == _b) return;
	var _k = string(min(_a, _b)) + ":" + string(max(_a, _b));
	// GOOD COMPANY (2026-09-17): either one's ability grows the pair's bond faster (a gain only)
	if (_n > 0) { var _sa = exped_sprite(_a), _sb = exped_sprite(_b), _bm = 1; if (!is_undefined(_sa)) _bm += sprite_ab(_sa).bonds / 100; if (!is_undefined(_sb)) _bm += sprite_ab(_sb).bonds / 100; _n *= max(.1, _bm); }   // (prickly, the flaw, can only slow it)
	var _was = g.bonds[$ _k] ?? 0;
	g.bonds[$ _k] = clamp(_was + _n, 0, 100);
	// MOODS (q261): a bond reaching mates is a good day for both, and heals a grief
	if (_was < 25 && g.bonds[$ _k] >= 25) { var _ma = exped_sprite(_a), _mb = exped_sprite(_b); if (!is_undefined(_ma) && !is_undefined(_mb)) { mood_event(_ma, "bond", "mates with " + _mb.name); mood_event(_mb, "bond", "mates with " + _ma.name); } }
	save_mark_dirty();
}
