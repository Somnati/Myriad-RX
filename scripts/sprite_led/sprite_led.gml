/// @description sprite_led(sprite, key, [n]) - a sprite's OWN ledger (his
/// ask, 2026-09-17: "individual sprite stats such as battles won, battles
/// lost, times died, dmg dealt, mistakes made, items found, distance
/// travelled"). Keys: trips / won / lost / downs / dmg / dtaken / mist /
/// finds / km. Saved as the sheet's thirteenth field (sprite_sheet_pack).
/// The sheet's second page reads it (syst_exped_panel's __draw_sheet_p2).
function sprite_led(_sp, _key, _n = 1) {
	if (!is_struct(_sp)) return;
	if (!is_struct(_sp[$ "led"])) _sp.led = {};
	_sp.led[$ _key] = (_sp.led[$ _key] ?? 0) + _n;
}
