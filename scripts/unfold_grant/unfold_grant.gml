/// @description unfold_grant(key, [banner], [quiet]) - THE ONE SITE a
/// feature unfolds: seen for good (unfold_has says yes from here on),
/// its banner shown, and - if it has a menu line - marked fresh so the
/// line wears "new" until the menu is opened. The objectives call it
/// as steps tick and objectives complete; unfold_tick calls it for the
/// time-gated rows (battery, bank, gift, sprite). quiet = no banner and
/// no fresh mark (a save catching up, a reveal-all).
function unfold_grant(_key, _banner = "", _quiet = false) {
	// the keys with a line in the menu (menu2_content) - the drawer, the
	// toys, the tap's own unlocks have none, so they never say "new"
	static _menu = ["upgrades", "tiles", "abilities", "automation", "timebank", "battery",
	                "ccore", "expeditions", "gift", "statistics", "offlog", "rebirth", "cheat"];
	unfold_init();
	if (g.unf.seen[$ _key] ?? false) return;
	g.unf.seen[$ _key] = true;
	if (!_quiet) {
		if (_banner != "") assign_banner(_banner, c_gold, c_black);
		if (array_contains(_menu, _key) && !array_contains(g.unf.fresh, _key)) array_push(g.unf.fresh, _key);
	}
	save_mark_dirty();
}
