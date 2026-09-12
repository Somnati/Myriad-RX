/// @description exped_init([force]) - THE EXPEDITION STATE (the mock,
/// his go 2026-09-12: "1 room with all this in a simple concept so I
/// can test how it feels"). The loop lives here and in exped_* -
/// syst_exped_panel is only its view - so the bench IS the spine.
///   board   the three destinations on offer (exped_board_roll)
///   trip    the trip under way, or undefined (exped_start / exped_tick)
///   haul    a returned trip's card waiting to be collected, or undefined
///   depth   the farthest tier the board may offer (chart fragments raise it)
///   charms  luck points found (luck_points reads it)
///   mats    the faked material families, name -> count
///   seq     trips started - the board's seed
///   spd     the debug clock: x1 / x10 / x100
///   log     the last trip's lines, for the panel
function exped_init(_force = false) {
	if (!_force && variable_global_exists("exped")) return;
	g.exped = { board : [], trip : undefined, haul : undefined,
	            depth : 1, charms : 0, mats : {}, seq : 0, spd : 1, log : [] };
	exped_board_roll();
}
