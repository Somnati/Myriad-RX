/// @description ui_overlay() - the full-screen panel currently up over
/// the room, or noone.
///
/// ⚖️ THE ONE ANSWER. Settings and statistics both stopped being rooms
/// (2026-09-08, his ask) and became panels drawn over whatever you are
/// standing in. Two things need to know that: syst_input, which holds
/// the room behind them quiet, and the burger, which becomes the X that
/// closes them. Asking each of those to name every overlay is how the
/// third one gets forgotten in one of the two places - so they ask here,
/// and adding an overlay is a line in this function.
///
/// Order is arbitrary because they are mutually exclusive by
/// construction: each open() refuses while another is up.
///
/// ⚖️ THE CONTRACT, as of the open animation (2026-09-09): anything
/// returned from here MUST carry `oa` (its 0..1 open ease) and
/// `closing`. ui_blur_tick reads oa off whatever is up so the blur
/// rides the panel in and out, and it would throw on a panel without
/// one. A new overlay is still one line here - plus those two
/// variables in its Create and the three-line ease in its Step.
function ui_overlay() {
	// ⚖️ THE ONE OPENING WINS OVER THE ONE LEAVING (his report, 2026-09-14:
	// "a lil weirdness" between the tiles and the cheat shop). An open()
	// folds whatever is up and spawns its own panel in the same step, so
	// for a few frames TWO exist - and the first in the list below used to
	// answer, which could be the one fading OUT: the blur followed its
	// ease down while the new panel's went up. A panel on its way out only
	// answers when nothing else is up
	static _list = [syst_settings, syst_statistics_v2, syst_timebank_panel, syst_gift_panel, syst_faq,
	                syst_automation_panel, syst_battery_panel, syst_welcome, syst_upgrades, syst_rm_ability,
	                syst_tiles, syst_ccore_panel, syst_exped_panel, syst_offlog, syst_objectives_panel, syst_cheat_panel,
	                syst_changelog];
	for (var _i = 0; _i < array_length(_list); _i++) {
		if (!instance_exists(_list[_i])) continue;
		var _inst = instance_find(_list[_i], 0);
		if (!_inst.closing) return _inst;
	}
	if (instance_exists(syst_settings))      return syst_settings;
	if (instance_exists(syst_statistics_v2)) return syst_statistics_v2;
	if (instance_exists(syst_timebank_panel)) return syst_timebank_panel;
	if (instance_exists(syst_gift_panel))     return syst_gift_panel;
	if (instance_exists(syst_faq))            return syst_faq;
	if (instance_exists(syst_automation_panel)) return syst_automation_panel;
	if (instance_exists(syst_battery_panel))    return syst_battery_panel;
	if (instance_exists(syst_welcome))          return syst_welcome;
	if (instance_exists(syst_upgrades))         return syst_upgrades;
	if (instance_exists(syst_rm_ability))       return syst_rm_ability;
	if (instance_exists(syst_tiles))            return syst_tiles;
	if (instance_exists(syst_ccore_panel))      return syst_ccore_panel;
	if (instance_exists(syst_exped_panel))      return syst_exped_panel;
	if (instance_exists(syst_offlog))           return syst_offlog;
	if (instance_exists(syst_objectives_panel)) return syst_objectives_panel;
	if (instance_exists(syst_cheat_panel))      return syst_cheat_panel;
	if (instance_exists(syst_changelog))        return syst_changelog;
	// the rebirth overlay counts only while it is up or still fading -
	// closed, the money room's instance is dormant furniture
	if (instance_exists(syst_rebirth) && (syst_rebirth.open || syst_rebirth.alpha > .01))
		return syst_rebirth;
	return noone;
}
