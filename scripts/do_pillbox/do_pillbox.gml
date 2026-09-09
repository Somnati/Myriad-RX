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

	// one box at a time: politely fold any other owner's box first,
	// through ITS owner (never the object name - no cross-talk)
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
