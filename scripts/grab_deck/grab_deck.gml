/// @description grab_deck() - replay the whole deck definition.
/// ported from Myriad DE: the caller sets `a` (which row it wants)
/// and this replays the batch scripts; ability() materializes the
/// matching row into the caller. batch offsets (o.batch_*) memoize
/// section boundaries so a slot deep in the list jumps straight to
/// its section instead of replaying everything before it. a_ == -1
/// = the controller's full pass: every batch runs and re-caps.
/// (GENERATED from scratchpad/build_deck.py's table, 2026-09-13)
function grab_deck() {
	o  = syst_rm_ability;
	oo = instance_exists(o);
	if (a_ == 0) if (oo) o.input_changed = true; // slot 0 wakes the system
	// defaults: what a row is when nothing materializes
	mx     = 0;
	_a     = 0;
	aid    = -1;
	input  = -1;
	name   = "ability info";
	apreq  = 0;
	rarity = 0;
	txt    = "tap an ability to read it.\ntap its ap chip to toggle it.";
	sub    = false;
	open   = true;
	_open  = true;
	tog    = true;
	flavor = 0;
	input_changed -= 1;
	ap_multi = 1; // Myriad's hardmode hook, kept as the seam
	title_color = rgb(255, 177, 168);
	f = 0;
	repeat (5) { flavor_text[f] = ""; flavor_color[f] = c_white; f++; }
	// rarity constants for the batch scripts
	common = 0; uncommon = 1; rare = 2; legendary = 3; epic = 4; premium = 5;
	// ---- the batches, in deck order ----
	cap_min = 0; cap_max = 0;
	cap_min = cap_max; if (oo) cap_max = o.batch_tapper;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_tapper();
	if (oo) _a = o.batch_tapper;
	cap_min = cap_max; if (oo) cap_max = o.batch_overcharge;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_overcharge();
	if (oo) _a = o.batch_overcharge;
	cap_min = cap_max; if (oo) cap_max = o.batch_dials;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_dials();
	if (oo) _a = o.batch_dials;
	cap_min = cap_max; if (oo) cap_max = o.batch_tiles;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_tiles();
	if (oo) _a = o.batch_tiles;
	cap_min = cap_max; if (oo) cap_max = o.batch_puck;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_puck();
	if (oo) _a = o.batch_puck;
	cap_min = cap_max; if (oo) cap_max = o.batch_upgrades;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_upgrades();
	if (oo) _a = o.batch_upgrades;
	cap_min = cap_max; if (oo) cap_max = o.batch_support;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_support();
	if (oo) _a = o.batch_support;
	cap_min = cap_max; if (oo) cap_max = o.batch_rebirth;
	if ((a >= cap_min && a < cap_max) || a_ == -1) grab_deck_rebirth();
	if (oo) _a = o.batch_rebirth;
	apreq = floor(apreq);
}
