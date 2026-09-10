/// @description do_pillbox(x, y, [type], [side]);
/// @param x     anchor (usually the tap point / control edge)
/// @param y
/// @param type  0 = picking a pill closes the box (single choice,
///              default); 1 = the box stays open (multi-toggle, the
///              owner closes it by setting _popen = false)
/// @param side  -1 auto by screen third (default), 0 = force the box
///              to open RIGHT of the anchor, 1 = force LEFT
/// @param sticky true = outside taps don't close it; a pick must be
///              made (the combat action menu's mode)
/// @param quiet  true = the box opens and picks SILENTLY. For lists you
///              AUDITION: the settings sound rows play the sound you
///              picked, and the pillbox's own pop landing on top of it
///              is the interface talking over the thing you asked to
///              hear (his report, 2026-09-08)
/// spawns the list built by set_pill() as one obj_pillbox per option.
/// while any box is open syst_input raises g.input_block to
/// ui_layer_popup, so the room behind it goes quiet with zero guard
/// code at call sites - the pills themselves clear the block via
/// their own ui_layer.
function do_pillbox(_x, _y, _type = 0, _side = -1, _sticky = false, _quiet = false) {

	// ⚖️ A RE-OPEN REPLACES ITS OWN BOX INSTANTLY (his report, 2026-09-09:
	// "i was able to open multiple pillboxes in the settings room").
	// The polite fold below could not cover this and the reason is
	// exact: it sets the OWNER's _popen false, and two lines later this
	// function sets the same flag true again. The old pills read that
	// flag on their NEXT step, see `true`, and never fade - so a second
	// full set spawns on top of a set that is now immortal. A STAYING
	// box makes it trivial to hit, because its _popen is still true
	// when you press the row again, which is the settings sound rows
	// and the dice-material row.
	//
	// Destroying is right rather than harsh: an owner re-opening its
	// own box is REPLACING it, and there is nothing to animate out of -
	// the new box lands in the same place the old one was.
	with (obj_pillbox) if (obj == other.id) instance_destroy();

	// other owners still fold politely, through THEIR owner (never the
	// object name - no cross-talk), so their box plays its exit
	with (obj_pillbox) if (instance_exists(obj)) obj._popen = false;

	var _n = array_length(_pills);
	if (_n == 0) return;

	// uniform width: the longest label decides for the whole stack
	draw_set_font(fnt);
	var _w = 0;
	for (var _i = 0; _i < _n; _i++) _w = max(_w, string_width(_pills[_i].name));

	_popen = true;
	if (!_quiet) play_sound_ext(snd_pop, .8, 1.2, .3, 1);

	for (var _i = 0; _i < _n; _i++) {
		var _o = create_obj(-1000, -1000, obj_pillbox);
		_o.depth = depth - 1;
		_o.obj   = id;
		_o.i     = _i;
		_o.pill  = _pills[_i]; // struct REFERENCE: owner edits relight live
		_o.all_h = 13 * _n;
		_o.des_w = _w + 6;
		_o.mx_   = _x;
		_o.my_   = _y;
		_o.type  = _type;
		_o.force_side = _side;
		_o.sticky = _sticky;
		_o.quiet  = _quiet;
	}
}
