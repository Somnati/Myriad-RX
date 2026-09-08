/// @description rebirth_do() - THE COMMIT (Myriad DE's do_rebirth +
/// the create_new_game wipe it delegates to). Refuses unless
/// rebirth_calc says can AND the press timer has run down; returns
/// true when the rebirth landed. Ceremony (sounds, motes, banner, the
/// wipe) belongs to syst_rebirth - this is the state change only.
///   1. THE BACKUP: the live state is written, then copied to save
///      slot 4 - the "rebirth save" the saves menu lists, DE's own
///      safety net for a rebirth you regret.
///   2. THE AWARD: units bank, total climbs, the run's report card.
///   3. THE CLEAN SLATE (DE's create_new_game -> create_new_auto per
///      dial -> create_new_clicker): profit to zero, every dial back
///      to level 0, the tap re-derived (it now carries the units).
///      SURVIVES by not being touched: the bank, lifetime profit and
///      taps, lifetime playtime, profile, settings, statistics pins.
///   4. THE RUN CLOCK restarts and everything saves at once.
function rebirth_do() {
	var _r = rebirth_calc();
	if (!_r.can || _r.cool > 0) return false;

	// ---- 1. the backup ----
	if (instance_exists(syst_handle_save)) {
		with (syst_handle_save) { action = sv_save; handle_save(); action = -1; }
		var _main = syst_handle_save.file_to_handle;
		var _bak  = save_slot_path(4);
		if (file_exists(_bak))  file_delete(_bak);
		if (file_exists(_main)) file_copy(_main, _bak);
	}

	// ---- 2. the award ----
	g.rebirth.prev_units  = _r.units;
	g.rebirth.prev_secs   = _r.run_s;
	g.rebirth.prev_profit = (g.profit >= arb(1)) ? g.profit : 0;
	g.rebirth.units = (g.rebirth.units >= arb(1))
		? do_add(g.rebirth.units, _r.units) : _r.units;
	g.rebirth.total += 1;

	// ---- 3. the clean slate ----
	g.profit        = 0;
	g.profit_flight = 0;
	// the reserve's watermark is RUN-scoped: automation prefs survive a
	// rebirth (they are preferences, not progress) but the high point
	// the reserve is measured against is a fact about the pile, and the
	// pile just went to zero. Leaving it would hold the whole of the
	// next run's early profit against a number from the last one.
	if (variable_global_exists("autom")) g.autom.lock_peak = 0;
	create_dials();   // levels 0, cycles 0, then update_dials -> update_click
	g.buy_lv = 1;

	// ---- 4. the run clock + the heavy save ----
	g.rebirth.run_pt0 = variable_global_exists("time_played_active") ? g.time_played_active : 0;
	save_mark_dirty();
	if (instance_exists(syst_handle_save)) {
		with (syst_handle_save) { action = sv_save; handle_save(); action = -1; }
		g.save_dirty = false;
	}
	show("[action] REBIRTHED  +" + crunch_arb(_r.units) + " units");
	return true;
}
