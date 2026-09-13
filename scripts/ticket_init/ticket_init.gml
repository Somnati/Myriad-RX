/// @description ticket_init([force]) - THE SCRATCH TICKETS' state (his
/// ask, 2026-09-13: "what about lottery tickets" - "build it"). Nothing
/// here is bought: tickets are EARNED (ticket_grant's sources) and the
/// scratch is the fidget. A new game wipes it; a rebirth keeps it (a
/// ticket on the desk is not run progress).
///   pile       the unscratched tickets, oldest first: { seed, rar, src }
///              (+ cells / cleared while one is being scratched -
///              session only, never saved)
///   scratched  lifetime tickets finished
///   won        ...that paid
///   best       the rarity of the best win (-1 none), best_txt its label
///   seq        the ticket counter (folds into each seed)
function ticket_init(_force = false) {
	if (variable_global_exists("tickets") && !_force) return;
	g.tickets = { pile : [], scratched : 0, won : 0, best : -1, best_txt : "", seq : 0 };
}
