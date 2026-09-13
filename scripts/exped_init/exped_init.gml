/// @description exped_init([force]) - THE EXPEDITION STATE (the mock,
/// his go 2026-09-12; parties + many trips at once, 2026-09-13). The
/// loop lives here and in exped_* - syst_exped_panel is only its view.
///   board   the three destinations on offer (exped_board_roll)
///   trips   every trip under way (exped_start / exped_tick), each its own
///   hauls   returned trips waiting to be collected (exped_collect)
///   depth   the farthest tier the board may offer (chart fragments raise it)
///   charms  luck points found (luck_points reads it)
///   mats    the faked material families, name -> count
///   seq     trips started - ids and the board's seed
///   spd     the debug clock: x1 / x10 / x100
///   recent  the diary's said-this-session ring (exped_say; not saved)
///   retired names of sprites swapped out for a recruit (exped_retire) -
///           the diary brings them up; names only, twelve at most
/// g.bonds (exped_bond) lives beside it: one number per pair of sprites.
function exped_init(_force = false) {
	if (_force || !variable_global_exists("bonds")) g.bonds = {};
	if (!_force && variable_global_exists("exped")) return;
	g.exped = { board : [], trips : [], hauls : [], depth : 1, charms : 0, mats : {}, seq : 0, spd : 1,
	            recent : [], retired : [] };
	exped_board_roll();
}
