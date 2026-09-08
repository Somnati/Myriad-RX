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
	g.units                  = 0;
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
	g.ad_title_survey  = -1;
	g.ad_title_fleet   = -1;
	g.ad_title_tiles   = -1;
	g.ad_title_colony  = -1;
	g.ad_title_combat  = -1;
	g.ad_title_support = -1;

	// ---- every ability, all placeholders for future systems. the
	// key list drives both init (-1 = locked) and the save section ----
	g.abi_keys = [
		// survey
		"ad_probespeed", "ad_probespeed2", "ad_multiprobe",
		"ad_deepscan", "ad_autosurvey",
		// fleet
		"ad_warptune", "ad_fuelcells", "ad_autopilot", "ad_deepspace",
		// tiles
		"ad_automerger", "ad_automerger2", "ad_fabricator",
		"ad_fabricator2", "ad_duplicator", "ad_tilerarity", "ad_hotswap",
		// colony
		"ad_cityloans", "ad_nightshift", "ad_census", "ad_terraformer",
		// combat
		"ad_initiative", "ad_counterschool", "ad_fieldmedic", "ad_warcry",
		// support
		"ad_onefinger", "ad_autobuy", "ad_aputilizer", "ad_luckcharm",
		"ad_notekeeper", "ad_bargain", "ad_deeppockets", "ad_scholar",
	];
	for (var _i = 0; _i < array_length(g.abi_keys); _i++)
		variable_global_set(g.abi_keys[_i], -1);
}
