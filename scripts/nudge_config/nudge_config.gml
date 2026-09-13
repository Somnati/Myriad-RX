/// @description nudge_config() -> THE NUDGES: a ring and one line, each
/// tied to a STATE (need) and a way to be done with it (done). No
/// clock, no script: a nudge shows while its state is true and its job
/// is not, and never again once the job is done. rect() may return
/// undefined (a line alone, at the foot of the room). Rows are in
/// priority order - the first live one shows (syst_nudge).
function nudge_config() {
	static _n = [
		// the first dial: the drawer's edge, once a hundred is near
		{ key : "dial", txt : "something is waiting on the right - pull it open",
		  need : function() { return unfold_has("dials") && variable_global_exists("dial") && g.dial[0].level == 0 && g.profit >= arb(60); },
		  done : function() { return variable_global_exists("dial") && g.dial[0].level > 0; },
		  rect : function() {
			if (!instance_exists(syst_dials)) return undefined;
			if (syst_dials.stage > 0) return undefined;
			return { x : syst_dials.face, y : 16, w : room_width - syst_dials.face, h : room_height - 16 };
		  } },
		// bought: it runs by itself
		{ key : "dial_runs", txt : "it pays by itself every few seconds - the bar is its cycle",
		  need : function() { return variable_global_exists("dial") && g.dial[0].level > 0 && g.dial[0].level < 3; },
		  done : function() { return variable_global_exists("dial") && g.dial[0].level >= 3; },
		  rect : function() { return undefined; } },
		// a fresh menu line: the burger, until the menu is opened
		{ key : "menu_fresh", txt : "",   // the line is built live (syst_nudge)
		  need : function() { return variable_global_exists("unf") && array_length(g.unf.fresh) > 0 && !instance_exists(syst_menu2); },
		  done : function() { return false; },   // never done - it clears itself when the menu opens
		  rect : function() { return { x : room_width - 26, y : 12, w : 24, h : 20 }; } },
		// the first roll, on the table
		{ key : "roll", txt : "a roll is an upgrade of a random kind and rarity - keep it, or sell it back",
		  need : function() { return instance_exists(syst_upgrades) && variable_global_exists("upg") && g.credits >= arb(upgrade_roll_cost()) && !upgrade_any_owned(); },
		  done : function() { return variable_global_exists("upg") && upgrade_any_owned(); },
		  rect : function() { if (!instance_exists(syst_upgrades)) return undefined; return syst_upgrades.__roll_rect(); } },
		// the pile, after an absence
		{ key : "pile", txt : "your absence paid into the pile - tap it",
		  need : function() { return variable_global_exists("offline_pool") && g.offline_pool >= arb(1) && instance_exists(obj_offlinegold); },
		  done : function() { return variable_global_exists("offline_pool") && !(g.offline_pool >= arb(1)); },
		  rect : function() {
			if (!instance_exists(obj_offlinegold)) return undefined;
			var _o = obj_offlinegold;
			return { x : _o.bbox_left - 2, y : _o.bbox_top - 2, w : _o.bbox_right - _o.bbox_left + 4, h : _o.bbox_bottom - _o.bbox_top + 4 };
		  } },
		// rebirth, the first time it is on the table
		{ key : "rebirth", txt : "the run can rebirth - everything resets, the boost stays",
		  need : function() { return unfold_has("rebirth") && variable_global_exists("rebirth") && g.rebirth.total == 0 && rebirth_calc().can && !instance_exists(syst_menu2); },
		  done : function() { return variable_global_exists("rebirth") && g.rebirth.total > 0; },
		  rect : function() { return { x : room_width - 26, y : 12, w : 24, h : 20 }; } },
		// the first expedition
		{ key : "send", txt : "pick a world, tap a crew, send them - then read what they write",
		  need : function() { return instance_exists(syst_exped_panel) && syst_exped_panel.view == "hub" && variable_global_exists("exped") && g.exped.seq == 0; },
		  done : function() { return variable_global_exists("exped") && g.exped.seq > 0; },
		  rect : function() { if (!instance_exists(syst_exped_panel)) return undefined; return syst_exped_panel.__card_r(0); } },
		// the gift, the first day
		{ key : "gift", txt : "a gift is waiting - once a day, in the menu",
		  need : function() { return unfold_has("gift") && variable_global_exists("gift") && g.gift.claims == 0 && gift_can_claim() && !instance_exists(syst_menu2) && ui_overlay() == noone; },
		  done : function() { return variable_global_exists("gift") && g.gift.claims > 0; },
		  rect : function() { return { x : room_width - 26, y : 12, w : 24, h : 20 }; } },
	];
	return _n;
}
