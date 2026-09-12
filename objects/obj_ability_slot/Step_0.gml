
o = syst_rm_ability;
if (!instance_exists(o)) { kill; exit; }

// the lens: my fixed row plus the (whole) page = my deck index.
// yos carries the fractional page remainder so scrolling is smooth
// while indexes snap
a = a_ + round(g.ability_page);
yos = o.row_h * (round(g.ability_page) - g.ability_page) + sos;
sos = trickle(sos, 0, 5);
alpha = trickle(alpha, 1, 5);

// rematerialize when my index moved or the system flagged a change
if (a != previous_a || input_changed > 0) grab_deck();
previous_a = a;

// snapshot BEFORE actions: only a real toggle differs afterward
previous_input = input;

// controller-issued actions (it owns the arbitrated clicks)
if (pending_inspect) {
	pending_inspect = false;
	// first inspection retires the "new" badge (native: 100 -> 0)
	if (input >= 100) input = 0;
}
if (pending_toggle) {
	pending_toggle = false;
	if (input >= 100) input = 1;         // a new ability's first toggle enables it
	else input = !input;
	play_sound_ext(snd_matclick2, (input == 1) ? 1.1 : .9, (input == 1) ? 1.2 : 1.0, .5, 1);
}

// write-back: my toggled input becomes the global again, the AP pool
// recomputes, and EVERY slot rematerializes - a child's `open` state
// depends on its parent's toggle, so siblings can't be left stale
if (input != previous_input) {
	return_deck();
	deck_failsafes(); // parent off -> children snap off too
	o.update_ap = true;
	o.input_changed = 2;
	with (obj_ability_slot) input_changed = 2;
}

// ---- creator: chain-spawn the next row until the list is covered
// (the native self-replicating list, kept) ----
if (instance_number(obj_ability_slot) < o.visible_rows + 1)
if (instance_number(obj_ability_slot) <= a_ + 1) {
	var _o = create_obj(x, y + o.row_h, obj_ability_slot);
	_o.a_ = a_ + 1;
	_o.depth = depth;   // the whole chain rides the controller's slot
}
