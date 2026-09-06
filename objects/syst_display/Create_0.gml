// Display Handler v1.0

g.fullscreen = true; // default: fullscreen. settings.ini overrides on load
g.screen_size = 2560;      // the LIVE size (portrait rooms park it at 144)
g.screen_size_user = 2560; // the CHOSEN size: what the player picked in
	// settings and what saves/restores. split from the live one so a
	// trip through a portrait room can't overwrite the player's choice.
	// scr_display1 validates it against scr_res_list on every swap.
g.fullscreen_borderless = true;
g.vsync = false;
// PORTRAIT FIT MARGIN: the share of the display HEIGHT that "fit" mode
// leaves clear for the OS window chrome - the title bar above and the
// taskbar below. GML has no work-area call, so this is the reserve.
// A PERCENTAGE, not pixels, because chrome scales with DPI: the title
// bar + taskbar are ~7% of the screen height at 100% and at 200% alike.
// 12 keeps ~6% at each end, which clears a standard Windows 11 bar with
// room to spare. Settings > display tunes it.
g.fit_margin = 12;
// ORIENTATION (2026-09-06, his ask): which SHAPE of room the game
// plays in. -1 AUTO (phone = portrait, desktop = landscape), 0 forced
// portrait, 1 forced landscape. Rooms that exist in both shapes are
// listed in room_pairs; goto_room resolves every destination through
// it, so this one number decides what you walk into. room_orient() is
// the reader - never test this global directly.
g.orient = -1;

fullscreen_disabled = false;
border = false;
minimize = false;
minimized = false;


des_w = 2560; des_h = 1440;
	_dis_w = display_get_width();
	_dis_h = display_get_height();
//_d_adj = ceil(max(_dis_w,_dis_h)*.005);
_d_adj = 1;
w = window_get_width(); h = window_get_height();


window_center();
surface_resize(application_surface,1920,1080);

// boot GUI mapping: the game STARTS fullscreen now (start_fullscreen
// in options_windows + scr_display1's boot hold-fire, 2026-07-12), so
// the load room's GUI draws need an explicit logical size. the old
// windowed boot got this implicitly (default gui == the small window);
// room-sized matches how obj_set_landscape / the fit swap set it
// everywhere else. ui_fadein is size-agnostic either way (it paints
// display_get_gui_width/height).
display_set_gui_size(room_width,room_height);

set_throwable();

// window chrome (minimize / fullscreen / quit): spawned ONCE here and
// persistent, so every room gets them without placing instances. they
// pin themselves to the current room's top-right each step. mobile has
// no window to manage, so it never spawns them at all
if (os_type != os_android && os_type != os_ios) {
	create_obj(0, 0, obj_display_minimize);
	create_obj(0, 0, obj_display_fullscreen);
	create_obj(0, 0, obj_display_quit);
}
