// Display Handler v1.0

g.fullscreen = true; // default: fullscreen. settings.ini overrides on load
g.screen_size = 2560;      // the LIVE size (portrait rooms park it at 144)
g.screen_size_user = 2560; // the CHOSEN size: what the player picked in
	// settings and what saves/restores. split from the live one so a
	// trip through a portrait room can't overwrite the player's choice.
	// scr_display1 validates it against scr_res_list on every swap.
g.fullscreen_borderless = true;
g.vsync = false;

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
