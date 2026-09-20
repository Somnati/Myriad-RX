/// @description mood_grief(sprite, name, bond) - A BUDDY LET GO (exped_retire, before the bonds are wiped): the survivor carries a `lost` stamp by the bond, and sinks (q261)
/// The kind grieve hardest (x1.4), the cheerful and the smug least (x.8,
/// x.6); grief keeps its own slow half-life in mood_tick (three hours of
/// playtime at a bond of sixty, longer for closer) and pulls the drive
/// down while it lasts; a new mate halves it (mood_event "bond")
function mood_grief(_sp, _name, _bond) {
	if (is_undefined(_sp) || _bond < 25) return;
	var _m = mood_init(_sp), _pn = mood_pers(_sp);
	var _mult = (_pn == "kind") ? 1.4 : ((_pn == "cheerful") ? .8 : ((_pn == "smug") ? .6 : ((_pn == "grumpy") ? 1.1 : 1)));
	var _g = clamp(_bond / 100 * _mult, 0, 1);
	if (is_struct(_m.lost) && _m.lost.gr > _g) return;   // (a heavier grief already held)
	_m.lost = { name : _name, bond : _bond, gr : _g, t : g[$ "time_played_active"] ?? 0 };
	_m.v = clamp(_m.v - .7 * _bond / 100 * _mult, -1, 1);
	_m.a = clamp(_m.a - .3, 0, 1);
	_m.why = _name + " was let go"; _m.why_t = g[$ "time_played_active"] ?? 0;
	save_mark_dirty();
}
