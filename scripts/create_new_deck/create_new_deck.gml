/// @description create_new_deck() - declare the ENTIRE ability deck's
/// state, ported from Myriad DE. runs at boot (setgame); the save's
/// "abilities" section restores over it.
///
/// THE INPUT LEGEND (one int per ability, the whole state):
///   -1  = locked: invisible, the deck cursor skips it entirely
///    0  = discovered but toggled OFF
///    1  = discovered and ON (its apreq is spent from the AP pool)
///    3  = section title row
///  >=100 = freshly discovered: wears the "new" badge until inspected
///
/// ADDING AN ABILITY = six native touchpoints, keep them in sync:
///   1. a key in g.abi_keys below (this is also its savefile field)
///   2. an ability() line in its grab_deck_<section> batch
///      (+ its mirror line in return_deck, SAME order)
///   3. a get_ap() line in grab_deck_ap (SAME cost as the batch line)
///   4. a send_ability() line in send_deck (discovery eligibility)
///   5. an unlock_ability() dispatch line in unlock_deck
///   6. a deck_card_info() entry (collection screen + meta lookups)
function create_new_deck() {

	// ---- the AP economy (enable budget, not a shop) ----
	g.ap          = 0; // remaining right now (maxap - enabled costs)
	g.maxap       = 0; // grows +2 per discovered ability (grab_deck_ap)
	g.maxap_spend = 0; // theoretical spend if everything was on
	g.curap_spend = 0; // spend across everything DISCOVERED

	// ---- discovery (units currency buys new abilities) ----
	g.units                  = 0;   // (unused since 2026-09-13: the deck spends g.rebirth.units, DE's currency)
	g.new_abilities_unlocked = 0;
	g.unlockable_abilities   = 0;
	g.new_ability_cost       = arb(1);
	g.abi_pool               = []; // eligible keys (was ability_pool.txt)
	// discovery ORDER is deterministic per save: rolled fresh each
	// boot, locked in by the first save
	g.abi_seed = irandom($7fffffff);

	g.ability_page = 0;

	// debug: waive the units cost on discovery (room toggle)
	g.abi_free = false;

	// loadout presets: three stored enable-sets (0 = empty slot,
	// else an array of 0/1 parallel to g.abi_keys)
	g.abi_loadout = [0, 0, 0];

	// the discovery DRAFT: up to 3 seeded candidate keys awaiting the
	// player's pick (units already paid). empty = no draft up
	g.abi_draft = [];

	// ---- section titles: HIDDEN (-1) until their section has at
	// least one discovered ability - update_deck_titles() derives
	// them, so a fresh deck shows nothing at all (native behavior) ----
	g.ad_title_tapper = -1;
	g.ad_title_overcharge = -1;
	g.ad_title_dials = -1;
	g.ad_title_tiles = -1;
	g.ad_title_puck = -1;
	g.ad_title_upgrades = -1;
	g.ad_title_support = -1;
	g.ad_title_rebirth = -1;

	// ---- THE ROSTER: Myriad DE's abilities, the ones our features can
	// carry (his ask, 2026-09-13; the placeholders are gone). ONE TABLE
	// in scratchpad/build_deck.py generates this list and every other
	// touchpoint (grab_deck_*, _ap, send/unlock/return_deck,
	// deck_card_info, update_deck_titles, deck_failsafes, the collection
	// map); the seats are hand-placed and read abi_on(key). The key
	// list drives both init (-1 = locked) and the save section ----
	g.abi_keys = [
		// tapper
		"ad_critrate1", "ad_critrate2", "ad_critrate3", "ad_critcut1", "ad_critcut2",
		"ad_critcut3", "ad_criticalsyphon", "ad_tappersyphon1", "ad_tappersyphon2",
		"ad_tappersyphon3",
		// overcharge
		"ad_chargercap", "ad_chargerate1",
		// dials
		"ad_patientpayload",
		// tiles
		"ad_fabricator", "ad_fabricator2", "ad_fabricator3", "ad_automerger2",
		"ad_automerger3", "ad_duplicator", "ad_duplicator2", "ad_tiermerger1",
		"ad_mergecharger", "ad_raritymerger",
		// puck
		"ad_th_bounce1", "ad_th_bouncegain2",
		// upgrades
		"ad_topgrade1", "ad_topgrade2", "ad_topgrade3", "ad_upgradetier",
		// support
		"ad_luckystrike", "ad_jackpot1", "ad_offlinecollect",
		// rebirth
		"ad_networth", "ad_resetbracer", "ad_resetbracer2",
	];
	for (var _i = 0; _i < array_length(g.abi_keys); _i++)
		variable_global_set(g.abi_keys[_i], -1);
}
