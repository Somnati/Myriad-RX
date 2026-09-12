if (!in_room(rm_clicker)) exit;
if (!variable_global_exists("scene_light") || g.scene_light <= 0) exit;
if (!surface_exists(application_surface)) exit;
var _aw = surface_get_width(application_surface);
var _ah = surface_get_height(application_surface);
if (_aw < 4 || _ah < 4) exit;
if (!__build(_aw, _ah)) exit;

// down the chain: the application surface into the half, then each
// link into the next, bilinear at exactly one half
gpu_set_tex_filter(true);
gpu_set_blendenable(false);
var _src = application_surface;
for (var _i = 0; _i < 6; _i++) {
	var _d = chain[_i];
	if (!surface_exists(_d)) { gpu_set_blendenable(true); gpu_set_tex_filter(false); exit; }
	surface_set_target(_d);
	draw_clear_alpha(c_black, 1);
	draw_surface_ext(_src, 0, 0,
		surface_get_width(_d)  / surface_get_width(_src),
		surface_get_height(_d) / surface_get_height(_src), 0, c_white, 1);
	surface_reset_target();
	_src = _d;
}
gpu_set_blendenable(true);
gpu_set_tex_filter(false);
tight = chain[2];   // an eighth of the surface: 240x135 on 1920x1080 - half room res
wide  = chain[5];   // a sixty-fourth: 30x17 - the wash
ready = true;
