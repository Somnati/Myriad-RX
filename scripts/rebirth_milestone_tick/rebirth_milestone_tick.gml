/// @description rebirth_milestone_tick() - THE MILESTONE LEDGER (2026-09-14
/// bug hunt): the highest rebirth milestone ever reached, g.rebirth.hi_ms,
/// used to be advanced by the milestone SCALE - a tap-room object - so a
/// 1e16 crossed while standing in the tiles or a panel counted for
/// nothing until the next visit home, and the cheat shop's cap (+25 a
/// milestone) and the milestone ticket waited with it. It advances here,
/// on every feed (rebirth_feed), wherever you are. The scales keep their
/// own `ms_seen` for the chime, so the ceremony still plays on arrival.
function rebirth_milestone_tick() {
	rebirth_init();
	var _p = rebirth_fed();
	if (!(_p >= arb(1))) return;
	var _lg = floor(_p) + max(0, ((frac(_p) * 10) - 1) / 9);   // DE's income (continuous log10)
	var _lv = ceil(max(0, (_lg - 16) / 10));
	if (_lv > g.rebirth.hi_ms) {
		g.rebirth.hi_ms = _lv;
		ticket_grant("milestone");   // a milestone's ticket - never a common
		save_mark_dirty();
	}
}
