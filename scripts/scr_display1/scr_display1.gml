/// @description script_name(val);
/// @param val
function scr_display1(){

// BOOT HOLD-FIRE (2026-07-12, the boot-lurch fix). the game now
// STARTS fullscreen (options_windows start_fullscreen: true), so the
// engine-load window is a black fullscreen instead of the tiny
// 144x296 portrait floater he watched appear at the left and lurch
// out to size. while the boot room is up, this driver holds fire -
// no portrait drop, no fit swap, no window trickle.
// round 3 (2026-07-13, "the saved setting must win"): the SAVED mode
// applies RIGHT HERE, behind ui_fadein's black cover. settings.ini
// lands on step 1 (syst_handle_save's load), so from the first step
// g.fullscreen is the player's choice, not the default:
//   - saved fullscreen (the default): the window already IS
//     fullscreen - zero window operations, ever.
//   - saved windowed: ONE silent drop + size to the chosen res while
//     the screen is still black, with w/h/des_* pre-seeded so the
//     titlescreen entry has NOTHING left to trickle - no visible
//     mode flap in either direction.
// everything else deferred here (minimize bookkeeping, throwable)
// re-runs on the first real room a step later.
if (room == rm_gameload) {
	// borderless preference applies behind the cover too - flipping it
	// at the titlescreen would be its own visible mode flap
	if (g.fullscreen_borderless != window_get_borderless_fullscreen())
		window_enable_borderless_fullscreen(g.fullscreen_borderless);
	if (!g.fullscreen && window_get_fullscreen()) {
		// the player's remembered size (same lookup + largest-option
		// fallback as the fit swap below; the swap heals the ini later
		// if the save traveled to a smaller monitor)
		var _bls = scr_res_list();
		var _bw2 = _bls[0].w; var _bh2 = _bls[0].h;
		for (var _bi = 0; _bi < array_length(_bls); _bi++)
			if (_bls[_bi].w == g.screen_size_user) {
				_bw2 = _bls[_bi].w; _bh2 = _bls[_bi].h; break;
			}
		window_set_fullscreen(false);
		window_set_size(_bw2, _bh2);
		window_set_position((display_get_width() - _bw2) div 2,
			max(0, (display_get_height() - _bh2) div 2));
		w = _bw2; h = _bh2; des_w = _bw2; des_h = _bh2;
		display_reset(0, abs(g.vsync)); // mode change drops the swapchain
	}
	exit;
}


if minimize = true{
		_adj_ = lerp(5,2,clamp((display_get_height()*.2)/point_distance(window_get_x(),window_get_y(),window_get_x(),display_get_height()),0,1));
		window_set_position(
	window_get_x(),
	trickle(window_get_y(),display_get_height()+5,_adj_,_d_adj)
	);
	
	if window_get_y() >= display_get_height() or window_get_fullscreen(){show("minimized");
		minimize = false;
		window_minimise();
	}
}



if window_get_width() = 0 minimized = true;

if g.vsync < 0 {g.vsync = abs(g.vsync); display_reset(0,g.vsync);}

if g.fullscreen = false
do_throwable(
window_get_x(),
window_get_y(),
display_get_width(),
display_get_height(),
window_get_width(),
window_get_height(),
display_mouse_get_x(),
display_mouse_get_y());

if window_get_width() = 0 minimized = true;

if window_get_width() != 0
if minimized = true minimized = -1;
	


_adj_ = lerp(10,2,clamp((display_get_height()*.2)/point_distance(window_get_x(),window_get_y(),_center_x-(window_get_width()/2),_center_y-(window_get_height()/2)),0,1));
if minimized = -1{
	_adj_ = lerp(5,2,clamp((display_get_height()*.2)/point_distance(window_get_x(),window_get_y(),_center_x-(window_get_width()/2),_center_y-(window_get_height()/2)),0,1));
	if window_get_x() = _center_x-(window_get_width()/2)
	if window_get_y() = _center_y-(window_get_height()/2)
	minimized = false;
}

if _center_y-(window_get_height()/2) < 0 _center_y = window_get_height()/2;

//if fullscreen_disabled = false
if g.fullscreen = false
if minimize = false
if _selected = false 
if window_get_x()+(window_get_width()/2) != _center_x
or window_get_y()+(window_get_height()/2) != _center_y{
	window_set_position(
	trickle(window_get_x(),_center_x-(window_get_width()/2),_adj_,_d_adj),
	trickle(window_get_y(),_center_y-(window_get_height()/2),_adj_,_d_adj)
	);
}

// Toggle g.fullscreen
if window_get_fullscreen() = true if g.fullscreen = false{//fullscreen_disabled = true;
	window_set_fullscreen(g.fullscreen);
	
	
	
	w = display_get_width();
	h = display_get_height();
	window_set_size(w,h);
	
	window_set_position(
	(display_get_width()/2)-(w/2),
	(display_get_height()/2)-(h/2) );

display_reset(0,g.vsync);
	
}

/*if fullscreen_disabled = true{show(" g.fullscreen disabled");
	_adj_ = lerp(1,5,clamp(point_distance(window_get_x(),window_get_y(),_center_x-(window_get_width()/2),_center_y-(window_get_height()/2))/(display_get_width()*.2),0,1));
	window_set_position(
	trickle(window_get_x(),_center_x-(window_get_width()/2),_adj_),
	trickle(window_get_y(),_center_y-(window_get_height()/2),_adj_)
	);
	
	if window_get_x() = _center_x-(window_get_width()/2)
	if window_get_y() = _center_y-(window_get_height()/2)
	fullscreen_disabled = false;
}*/

if g.fullscreen = true
	if window_get_width() = display_get_width()
	if window_get_height() = display_get_height()
	if window_get_x() = (display_get_width()/2)-(window_get_width()/2)
	if window_get_y() = (display_get_height()/2)-(window_get_height()/2)
	if window_get_fullscreen() = false{
		window_set_fullscreen(g.fullscreen);
		display_reset(0,g.vsync);
}






//if g.fullscreen != window_get_fullscreen() {
//window_set_fullscreen(g.fullscreen);
//display_reset(0,g.vsync);


//}

if g.fullscreen_borderless != window_get_borderless_fullscreen() {
	window_enable_borderless_fullscreen(g.fullscreen_borderless);

}

if true = false
if window_get_width()
if surface_get_width(application_surface) != window_get_width()
or surface_get_height(application_surface) != window_get_height(){
	surface_resize(application_surface,window_get_width(),window_get_height());
	
}

if not instance_exists(obj_set_landscape) if g.screen_size != 144 g.screen_size = -144;

// portrait (mobile-aspect) rooms can't present inside a landscape
// fullscreen, and the swap below is gated on windowed, so a fullscreen
// entry used to leave the window and gui uncorrected forever. desktop
// fix: drop to windowed so the swap can fit the room's aspect, remember
// it, and restore fullscreen when a landscape room takes over.
// (android never enters here: app_resize owns mobile display)
if !variable_instance_exists(id,"fs_restore") fs_restore = false;
if os_type = os_windows or os_type = os_macosx or os_type = os_linux {
	if g.fullscreen = true if g.screen_size < 0 if room_height > room_width {
		g.fullscreen = false;
		fs_restore = true;
		show("fullscreen dropped > portrait room");
	}
	if instance_exists(obj_set_landscape) if fs_restore = true {
		fs_restore = false;
		g.fullscreen = true;
		show("fullscreen restored > landscape room");
	}
}

if g.fullscreen = false
if g.screen_size < 0{g.screen_size = abs(g.screen_size); show("swap g.screen_size");

if g.screen_size = 144 {
	// "FIT" mode: a portrait/mobile-aspect room scales to the display
	// HEIGHT. It used to take _dis_h RAW and then pin the window at
	// y 0, which on Windows costs the room twice: the title bar goes
	// off the top of the screen (so the window can no longer be
	// dragged) and the bottom stripe of the room sits behind the
	// taskbar. His report 2026-09-04 - the menu's foot band drew its
	// "profit" / "time played" labels and hid the numbers under them,
	// because on a 1080 display a 48px taskbar eats the last 13 of the
	// room's 296 rows, and the values live at row 284.
	// g.fit_margin (percent, settings > display) is the reserve for
	// that chrome; the window then centres in the display, so half the
	// reserve sits above the title bar and half below the taskbar.
	var _res = _dis_h * (clamp(g.fit_margin, 0, 40) / 100);
	var _use = max(240, _dis_h - _res);
	var _fs  = _use / room_height;
	des_w = room_width * _fs;
	des_h = room_height * _fs;
	// tell the throwable window system where the window now lives, or
	// its trickle drags it back toward a stale centre and undoes this
	_center_x = _dis_w * .5;
	_center_y = _dis_h * .5;
	window_center();
}
else {
	// the swap used to be a hardcoded if-chain of five sizes offered
	// no matter the monitor. scr_res_list is now the ONE table (the
	// settings screen's resolution radios build from the same call,
	// so a picked size always resolves here). a saved size this
	// display can't hold - the save traveled to a smaller monitor -
	// falls back to the largest option and corrects the remembered
	// choice so settings.ini heals itself on the next write.
	var _ls = scr_res_list();
	var _hit = false;
	for (var _i = 0; _i < array_length(_ls); _i++)
		if (_ls[_i].w == g.screen_size) { des_w = _ls[_i].w; des_h = _ls[_i].h; _hit = true; break; }
	if (!_hit) {
		des_w = _ls[0].w; des_h = _ls[0].h;
		g.screen_size = des_w;
		g.screen_size_user = des_w;
		show("screen_size fallback > " + string(des_w));
	}
}

//surface_resize(application_surface,window_get_width(),window_get_height());
display_set_gui_size(room_width,room_height);

}

_des_w = des_w; _des_h = des_h;
if g.fullscreen = true {
	_des_w = display_get_width();
	_des_h = display_get_height();
	

	window_set_position(
	trickle(window_get_x(),(display_get_width()/2)-(window_get_width()/2),3,_d_adj),
	trickle(window_get_y(),(display_get_height()/2)-(window_get_height()/2),3,_d_adj));
	
}

if _des_w != window_get_width() or _des_h != window_get_height(){

w = trickle(w,_des_w,3,_d_adj);
h = trickle(h,_des_h,3,_d_adj);
if point_distance(w,0,_des_w,0) < max(_dis_w,_dis_h)*.01 w = _des_w;
if point_distance(h,0,_des_h,0) < max(_dis_w,_dis_h)*.01 h = _des_h;
//w = round(w);
//h = round(h);

//w_diff = round(w-window_get_width());
//h_diff = round(h-window_get_height());
//display_reset(0,g.vsync);
window_set_size(w,h);

//surface_resize(application_surface,w,h); // NEW
//display_reset(0,g.vsync); // NEW
//window_set_position(window_get_x()-(w_diff/2),window_get_y()-(h_diff/2));

}


	

}