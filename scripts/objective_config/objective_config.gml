/// @description objective_config() -> THE OBJECTIVES, in order (his spec,
/// 2026-09-13, after the nudges: "a list of objectives you have to
/// complete 1 by 1 with some sort of text based popup active in the
/// clicker room and a more detailed version on the hamburger menu").
/// One row an objective; each has STEPS with a checkbox, done when its
/// state says so (done()) or when the game has SEEN the player do it
/// (flag - objective_tick watches the drawer, the menu, the panels).
/// A step may carry `unlocks` - unfold keys granted the moment it
/// completes (the drawer arrives when a hundred is gathered, upgrades
/// with the first credit) - and an objective may carry `reward`,
/// granted when every step is done: the things that are NOT on by
/// default (his list: critical taps, the overcharger, the dice, the
/// puck). The chain is strictly sequential - objective_tick works only
/// row g.obj.i - so nothing time-gated lives here: the battery, the
/// bank, the gift, the sprite arrive by the game's numbers
/// (unfold_config). Edit the chain here; the card and the panel are
/// views over it.
///   { key, name, steps : [{ txt, done() | flag, unlocks?, banner? }],
///     reward?, reward_txt? }
function objective_config() {
	static _c = [
		{ key : "dial1", name : "buy your first dial",
		  steps : [
			{ txt : "gather 100 profit", unlocks : ["dials", "statistics"], banner : "something on the right",
			  done : function() { return variable_global_exists("dial") && (g.profit >= arb(100) || g.dial[0].level > 0); } },
			{ txt : "swipe left to view dials", flag : "drawer1" },
			{ txt : "click dial a to purchase",
			  done : function() { return variable_global_exists("dial") && g.dial[0].level > 0; } },
		  ] },
		{ key : "level10", name : "level up your dial",
		  steps : [
			{ txt : "swipe left to view dials", flag : "drawer1" },
			{ txt : "swipe left again to view dial upgrades", flag : "drawer2" },
			{ txt : "level dial a to lv 10",
			  done : function() { return variable_global_exists("dial") && g.dial[0].level >= 10; } },
		  ],
		  reward : ["crit"], reward_txt : "critical taps - one tap in twenty pays x1.5 to x5" },
		{ key : "dial2", name : "a second dial",
		  steps : [
			{ txt : "purchase dial b",
			  done : function() { return variable_global_exists("dial") && g.dial[1].level > 0; } },
		  ],
		  reward : ["overcharge"], reward_txt : "the overcharger - tapping charges a multiplier" },
		{ key : "credit1", name : "the first credit",
		  steps : [
			{ txt : "earn a credit (a running dial drops them on taps)", unlocks : ["upgrades"], banner : "a credit - the menu has a use for it",
			  done : function() { return variable_global_exists("total_credits") && g.total_credits >= arb(1); } },
			{ txt : "open the menu", flag : "menu" },
			{ txt : "open upgrades", flag : "upg_open" },
			{ txt : "roll an upgrade",
			  done : function() { return variable_global_exists("upg") && g.upg.rolls >= 1; } },
		  ],
		  reward : ["dice"], reward_txt : "dice on the table - something to fidget with" },
		{ key : "dial3", name : "a third dial",
		  steps : [
			{ txt : "purchase dial c", unlocks : ["automation"], banner : "new: automation",
			  done : function() { return variable_global_exists("dial") && g.dial[2].level > 0; } },
		  ] },
		{ key : "autom", name : "automation",
		  steps : [
			{ txt : "open automation from the menu", flag : "autom_open" },
			{ txt : "switch on an autobuy",
			  done : function() {
				if (!variable_global_exists("autom")) return false;
				if (g.autom.dial_all.on) return true;
				for (var _i = 0; _i < array_length(g.autom.dial); _i++) if (g.autom.dial[_i].on) return true;
				return g.autom.tap.on;
			  } },
		  ],
		  reward : ["puck"], reward_txt : "a puck - fling it" },
		{ key : "tiles", name : "the tile table",
		  steps : [
			{ txt : "purchase dial d", unlocks : ["tiles"], banner : "new: tiles",
			  done : function() { return variable_global_exists("dial") && (g.dial[3].level > 0 || g.profit >= arb(100000)); } },
			{ txt : "open tiles from the menu", flag : "tiles_open" },
			{ txt : "merge two tiles",
			  done : function() { return variable_global_exists("tiles") && g.tiles.merges >= 1; } },
		  ] },
		{ key : "abil", name : "abilities",
		  steps : [
			{ txt : "earn 10 credits", unlocks : ["abilities"], banner : "new: abilities",
			  done : function() { return variable_global_exists("total_credits") && g.total_credits >= arb(10); } },
			{ txt : "open abilities from the menu", flag : "abil_open" },
			{ txt : "draft a card",
			  done : function() { return variable_global_exists("new_abilities_unlocked") && g.new_abilities_unlocked >= 1; } },
		  ] },
		{ key : "ccore", name : "the credit core",
		  steps : [
			{ txt : "earn 15 credits", unlocks : ["ccore"], banner : "new: the credit core",
			  done : function() { return variable_global_exists("total_credits") && g.total_credits >= arb(15); } },
			{ txt : "open the credit core from the menu", flag : "ccore_open" },
			{ txt : "buy its first level",
			  done : function() { return variable_global_exists("ccore") && g.ccore.lv > 0; } },
		  ] },
		{ key : "rebirth", name : "rebirth",
		  steps : [
			{ txt : "hold a million profit", unlocks : ["rebirth"], banner : "new: rebirth",
			  done : function() { return variable_global_exists("rebirth") && (g.profit >= arb(1000000) || g.rebirth.total > 0); } },
			{ txt : "open rebirth from the menu", flag : "rebirth_open" },
			{ txt : "rebirth",
			  done : function() { return variable_global_exists("rebirth") && g.rebirth.total > 0; } },
		  ] },
	];
	return _c;
}
