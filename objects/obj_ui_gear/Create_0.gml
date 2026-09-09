/// obj_ui_gear - the settings gear (Myriad DE's spr_quickoption_settings,
/// imported as spr_gear). A door, not a menu entry: settings is the one
/// destination you reach mid-anything, so it gets a place of its own
/// rather than a line in a list. Its line came out of menu2_content the
/// day this landed.
///
/// TWO HOMES, one object, and they want different corners:
///   in game    it rides the OPEN drawer's left edge at the BOTTOM,
///              sliding in with it. Closed, there is no gear at all -
///              the header keeps the burger alone (his call).
///   title      bottom right, where nothing else lives (the version
///              strings hold the bottom LEFT).
/// Nothing here gates on g.game_started the way obj_ui_menu2 does:
/// having no run yet is precisely when you want display and audio.

depth = instance_exists(obj_ui_header) ? obj_ui_header.depth - 1 : -1001;

hot = false;
tic = 0;   // press debounce, obj_ui_menu2's
rip = 0;   // press ripple, 1 -> 0
spin = 0;  // hover ease, 0..1. It drives the angle and the scale
           // TOGETHER, so the whole hover state is one number: a quarter
           // turn and a little bigger on the way in, both unwinding on
           // the way out. It turns about its own middle, which is
           // spr_gear's origin doing the work rather than a half-width
           // subtraction - draw_sprite_ext rotates about the ORIGIN, so
           // with the imported top-left origin the icon orbited its
           // corner instead of turning on the spot.

/// where the gear sits this frame, and how visible it is.
/// `a` 0 means it is not there at all - Step and Draw both leave on it,
/// so there is one answer to "is the gear up" rather than two.
__seat = function() {
	// THE TITLE SCREEN has no menu to hang off, so the icon takes the
	// bottom right corner outright.
	if (!instance_exists(obj_ui_menu2))
		return { x : room_width - 15, y : room_height - 15, a : 1 };

	// IN GAME it belongs to the drawer, not to the header: it appears
	// when the menu opens and rides the panel's left edge in, which is
	// what makes it read as part of the menu rather than as a second
	// permanent button competing with the burger.
	if (!instance_exists(syst_menu2)) return { x : 0, y : 0, a : 0 };
	var _m = syst_menu2;
	return {
		x : _m.panel_x - 16,
		// THE BOTTOM of the drawer (his call, 2026-09-08): level with
		// the pinned time-played band rather than the header, so the
		// icon sits with the panel's furniture instead of competing
		// with the burger's X directly across from it.
		y : room_height - _m.foot_h * .5,
		a : clamp((room_width - _m.panel_x) / _m.pw, 0, 1),
	};
};
