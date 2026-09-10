/// syst_unfold - THE VEIL (his spec, 2026-09-10): a fresh run opens on
/// a black screen that says "tap". It IS the money room - everything
/// is there underneath - but nothing shows until the first tap, and
/// then it all fades in. "DE did this but was more incremental with
/// it. this is the first step to unfolding mechanics."
///
/// ONE OBJECT, drawn over everything (depth -1500: over the header at
/// -1000 and the menu at -520), so "every element hidden" is one black
/// rectangle and "they fade in" is that rectangle leaving - not a
/// reveal alpha threaded through thirty objects. g.unfold is the
/// state: 0 = veiled (game_reset sets it), 1 = revealed (the first
/// tap sets it, and it is saved, so the veil is a once-per-run thing).
///
/// THE FIRST TAP IS A REAL TAP. The veil holds the room's input at the
/// modal rung (syst_input reads it) so nothing underneath - the burger,
/// the rebirth banner, a die - can catch the press by accident, and
/// fires the tap itself through tap_fire: the payout, the crit roll,
/// the motes into the header, exactly the press obj_clicker would
/// have made. Then it lets go and fades.
///
/// SPAWNED BY syst_offline whenever the money room lacks one while
/// g.unfold is 0 - a runtime instance, both room shapes, the pile's
/// arrangement.

depth = -1500;
veil  = 1;       // the black, 1 opaque .. 0 gone
armed = (variable_global_exists("unfold") && g.unfold == 0);
pt    = 0;       // the word's breath
