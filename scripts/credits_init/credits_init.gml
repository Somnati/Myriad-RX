/// @description credits_init([force]) - THE CREDIT LAYER's state
/// (Myriad DE's g.credits / g.total_credits / g.cd_val). Credits are
/// the SECOND currency: profit buys dial levels, credits buy upgrades.
/// They SURVIVE REBIRTH (DE never touches them in do_rebirth); only a
/// new game wipes them (force = true from game_reset).
///   g.credits        the balance, a packed arb once it holds anything
///                    (plain 0 while empty - the house arb rule)
///   g.total_credits  lifetime earned, same packing
///   g.credit_pool    THE DROPPER's pool (DE's cd_val): refills over
///                    time up to g.credit_cap, every drop pulls from it
///   g.credit_cool    seconds left on the after-drop cooldown
/// The knobs live in setgame's Create beside the milestone table.
function credits_init(_force = false) {
	if (variable_global_exists("credits") && !_force) return;
	g.credits       = 0;
	g.total_credits = 0;
	g.credit_pool   = 0;
	g.credit_cool   = 0;
}
