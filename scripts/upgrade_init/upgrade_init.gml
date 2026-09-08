/// @description upgrade_init([force]);
/// @param [force]
/// THE UPGRADE STATE, and the only thing a save stores about it.
///
/// ⚖️ WHAT IS STORED IS WHAT YOU OWN, NEVER WHAT IT DOES. A slot keeps
/// its id, rarity, rolled value and tier - nothing else. Every effective
/// number derives from those at read time (upgrade_bonus), which is the
/// same law the dials follow and the one place Myriad DE breaks it:
/// there, buy_upgrade does `g.u_tapprofit += val` at purchase, so the
/// live numbers depend on the HISTORY of purchases rather than on what
/// you hold. That is why selling is awkward in DE (it has to subtract
/// back out), why a rebalance can never reach an old save, and why any
/// drift is permanent. Derived, all three problems stop existing.
///
/// SURVIVES REBIRTH (his call, DE's behaviour): credits and upgrades
/// are the PRESENCE layer, earned by being here and tapping, running
/// parallel to rebirth's PROGRESS layer. game_reset wipes it; rebirth
/// does not touch it.
function upgrade_init(_force = false) {
	if (!_force && variable_global_exists("upg")) return;

	g.upg = {
		// one entry per slot: a struct while it holds an offer, or -1
		// while the slot is empty and waiting for a roll
		slot   : array_create(UPG_SLOT_MAX, -1),
		bought : 0,   // extra slots bought (the "another slot" grant)
		total  : 0,   // lifetime purchases, for the statistics screen
		rolls  : 0,   // lifetime rolls, ditto
	};
}
