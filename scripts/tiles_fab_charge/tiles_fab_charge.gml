/// @description tiles_fab_charge(frac) - CHARGE THE FABRICATOR by a
/// fraction of a full bar (DE's merge charge, his ask 2026-09-13: a fab
/// sprite's tap "increases the fabrication on a tap relative to its
/// bonus... DE had an ability called merge charge that increased the
/// fab in a smart way"). DE's law, term for term: module_timer_tic +=
/// module_timer_tic_ x add. THE OVERFLOW carries: a charge past the top
/// finishes a tile and keeps the remainder, and a charge past two tops
/// finishes two (tiles_fab_finish, which also clamps when the table is
/// full). The view is told (a "charge" event) so the bar GROWS to the
/// new fill over a moment instead of jumping - DE's adj = 30.
/// @param frac  of a full bar, e.g. .05 = five percent
function tiles_fab_charge(_frac) {
	tiles_init();
	var _t = g.tiles;
	if (_frac <= 0) return;
	_t.fab += _t.fab_t * _frac;
	var _guard = 0;
	while (_t.fab >= _t.fab_t && _guard++ < 16) {
		if (!tiles_fab_finish()) break;
	}
	if (array_length(_t.ev) < 12) array_push(_t.ev, { k : "charge", i : -1, b : false });
}
