/// @description exped_open() - the expedition bench, over the room (it opens on the board's world - the hub went, his call 2026-09-16)
/// mode "sprites" (2026-09-16, his ask): the crew page as THE SPRITE MENU - the roster, the sheet, [dismiss]; no expedition
/// strip, no [back]; sid = the sprite to open on (a poke on a room blob)
function exped_open(_mode = "exped", _sid = -1) {
	if (instance_exists(syst_exped_panel) && syst_exped_panel.closing) {
		syst_exped_panel.closing = false;
		if (_mode == "sprites") { syst_exped_panel.mode = "sprites"; syst_exped_panel.view = "crew"; syst_exped_panel.crew_trip = -1; if (_sid >= 0) syst_exped_panel.sheet_id = _sid; }
		return;
	}
	if (instance_exists(syst_exped_panel)) { if (_mode == "sprites" && _sid >= 0) { syst_exped_panel.sheet_id = _sid; if (syst_exped_panel.view != "crew") { syst_exped_panel.crew_from = syst_exped_panel.view; syst_exped_panel.__page_go("crew"); syst_exped_panel.crew_trip = -1; } } return; }   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// a panel already up FOLDS (2026-09-13: the burger opens the menu over
	// a panel now, so a menu line must be able to swap panels)
	if (ui_overlay() != noone) ui_overlay_close();
	var _pnl = create_obj(0, 0, syst_exped_panel);
	if (_mode == "sprites") { _pnl.mode = "sprites"; _pnl.view = "crew"; _pnl.crew_trip = -1; _pnl.crew_from = "crew"; if (_sid >= 0) _pnl.sheet_id = _sid; }
}
