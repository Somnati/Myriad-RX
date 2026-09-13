/// @description unfold_init([force]) - THE UNFOLD's state (his spec,
/// 2026-09-13: "unfold so hard the game starts as just a black screen").
/// The veil (syst_unfold, g.unfold) is the first fold: a black screen
/// that says tap. Everything after it ARRIVES - the dial drawer, the
/// menu's lines, the toys, the chip, the pile - each when the game
/// says so (unfold_config), each with a banner and a nudge (syst_nudge).
///   seen    key -> true once a feature has unfolded (unfold_has)
///   done    key -> true once a nudge's job is done (never again)
///   opened  key -> true once a panel has been opened and closed (its
///           first-open line shows until then)
///   fresh   keys that unfolded and whose menu line has not been
///           visited yet (the burger's ring)
/// Saved in section "unfold". A save from before the unfold (dial a
/// owned, no unf_seen key) reveals everything - nobody is re-taught.
function unfold_init(_force = false) {
	if (!_force && variable_global_exists("unf")) return;
	g.unf = { seen : {}, done : {}, opened : {}, fresh : [], last_ov : noone, tic : 0 };
}
