
// ⚖️ THE DISPLAY MOUSE, NOT THE WINDOW MOUSE, on desktop (his ask,
// 2026-09-10: in windowed mode the in-game pointer froze where it
// left the window). window_mouse_get_x stops updating once the OS
// cursor leaves the window; display_mouse_get_x keeps reporting in
// desktop space, so subtracting the window's own position gives the
// same number inside the window and a live one outside it. Mobile
// keeps the window read - there is no desktop to be off.
if (os_type == os_windows || os_type == os_macosx || os_type == os_linux) {
	wmx = display_mouse_get_x() - window_get_x();
	wmy = display_mouse_get_y() - window_get_y();
} else {
	wmx = window_mouse_get_x();
	wmy = window_mouse_get_y();
}
wmx = wmx/(window_get_width()/room_width);
wmy = wmy/(window_get_height()/room_height);

//toggle touch
if mouse_check_button(mb_left)
    if on_screen = false{
on_screen = true;
drag_dist = 0;
x_ = mousex;
y_ = mousey;
x_prev = x_;
y_prev = y_;}

if mouse_check_button_released(mb_left) {
on_screen = false;
//x = 0;
//y = 0;
time = 0;
}


s = 1; if delta > 3.2 s = 1+(.08*delta);
//set vars
if on_screen = true{
x = x_-mousex;
y = y_-mousey;
time += delta;
drag_dist += point_distance(mousex,mousey,x_prev,y_prev);
//dragspdlerp = move_to(dragspdlerp,dragspd,5);
dragspd = point_distance(mousex,mousey,x_prev,y_prev)/(delta/s);
dragspdlerp = dragspd;
dir = point_direction(touch_x_,touch_y_,mousex,mousey);
x_prev = mousex; y_prev = mousey;
}



/*
legacy
mousex = (room_width/display_get_width())*device_mouse_raw_x(0)






/* */
/*  */


//two finger / pinch
//device 0 doubles as the mouse on pc, device 1 only ever fires on a
//real touchscreen, so pinch state is simply dead on desktop
t0x = device_mouse_x_to_gui(0); t0y = device_mouse_y_to_gui(0);
t1x = device_mouse_x_to_gui(1); t1y = device_mouse_y_to_gui(1);

touches = 0;
if device_mouse_check_button(0,mb_left) touches += 1;
if device_mouse_check_button(1,mb_left) touches += 1;

pinch_delta = 0; pinch_scale = 1;

if touches = 2{
pinch_cx = (t0x+t1x)/2;
pinch_cy = (t0y+t1y)/2;

if pinching = false{pinching = true;
pinch_dist = point_distance(t0x,t0y,t1x,t1y);
pinch_dist_prev = pinch_dist;}
else{
pinch_dist_prev = pinch_dist;
pinch_dist = point_distance(t0x,t0y,t1x,t1y);
pinch_delta = pinch_dist-pinch_dist_prev;
if pinch_dist_prev > 0 pinch_scale = pinch_dist/pinch_dist_prev;}
}
else pinching = false;
