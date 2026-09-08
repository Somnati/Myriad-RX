/// obj_ui_gear - the settings gear (Myriad DE's spr_quickoption_settings,
/// imported as spr_gear). A door, not a menu entry: settings is the one
/// destination you reach mid-anything, so it gets a fixed corner rather
/// than a line in a list you have to open first.
///
/// TWO HOMES, one object. obj_ui_header spawns it wherever the header
/// goes, and rm_titlescreen seats its own - which is why nothing here
/// gates on g.game_started the way obj_ui_menu2 does. The title screen
/// having no run yet is exactly when you want the display and audio
/// settings.

depth = instance_exists(obj_ui_header) ? obj_ui_header.depth - 1 : -1001;

hot = false;
tic = 0;   // press debounce, obj_ui_menu2's
rip = 0;   // press ripple, 1 -> 0
spin = 0;  // it turns a little when you are on it, because a cog should

/// where the gear sits. LEFT OF THE BURGER when there is one (his ask),
/// and in the burger's own corner slot when there is not - the title
/// screen has no menu, so the icon takes the corner rather than sitting
/// beside an empty space.
__seat = function() {
	if (instance_exists(obj_ui_menu2)) return { x : room_width - 37, y : 22 };
	return { x : room_width - 15, y : 22 };
};
