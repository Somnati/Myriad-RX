/// THE BOOT'S SCREEN (his ask, 2026-09-16: "a smooth minimal loading icon";
/// 2026-09-17, his call: "the loading screen on boot needs to go"): black
/// while the load runs - a frame or two - and the spinner (loading_draw, the
/// very one the expedition panel's veil uses now) only if the load itself
/// takes its time, three quarters of a second in. The galaxy no longer
/// charts here; it charts in the background (the Step)
if (!in_room(rm_gameload) || boot_phase >= 3) exit;   // (3 = done; 2 = the chart phase draws here too - q256)
// the gui at the window's size (the room behind is a stub of another shape;
// the rooms set it back to their own on arrival - obj_set_landscape /
// syst_display / scr_display1)
var _ww = max(120, window_get_width()), _wh = max(68, window_get_height());
display_set_gui_size(_ww, _wh);
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
// the whole gui black first
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, _gw, _gh, 0, c_black, 1);
if (boot_t <= 45) exit;
var _sc = max(1, floor(_gh / 270));                 // the house scale: one room pixel in window pixels
loading_draw(_gw - 20 * _sc, _gh - 22 * _sc, _sc, (boot_world != "") ? boot_world : "loading", boot_prog_v, c_steelblue);   // (the chart phase names its work - q256)
