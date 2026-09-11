if (!__on()) exit;
if (!surface_exists(application_surface)) exit;

// ---- capture what has drawn so far ----
// pixel_snap's idiom (the dial drawer's backdrop, live since 09-06):
// surface_set_target moves the render target off the application
// surface and flushes, so it is an ordinary texture by then. Blending
// off for the copy: an exact byte-for-byte frame, alpha included.
var _aw = surface_get_width(application_surface);
var _ah = surface_get_height(application_surface);
if (_aw < 2 || _ah < 2) exit;
if (!surface_exists(scratch) || surface_get_width(scratch) != _aw
|| surface_get_height(scratch) != _ah) {
	if (surface_exists(scratch)) surface_free(scratch);
	scratch = surface_create(_aw, _ah);
}
if (!surface_exists(scratch)) exit;
gpu_set_tex_filter(false);
gpu_set_blendenable(false);
surface_set_target(scratch);
draw_clear_alpha(c_black, 1);
draw_surface_ext(application_surface, 0, 0, 1, 1, 0, c_white, 1);
surface_reset_target();
gpu_set_blendenable(true);
t += delta / 60;

// ---- the bloom ----
// THE BRIGHT PASS, without a shader: the frame drawn into a half-size
// float surface, then drawn AGAIN over itself in multiply (dest colour
// x source, nothing of the old) - the frame SQUARED, so a white line
// of text stays 1 while a .4 block drops to .16: the bright things
// spill, the lit blocks glow a little, the dark field not at all
// (cubed, the blocks got nothing; squared at 1.6x, everything hazed -
// the power and the strength are two knobs). Then the tube's own chain (see the Create)
// blurs it at five widths and sums them, and the top link is the
// shader's second texture. Reads the application surface, so it runs
// here, before the tube draws over it.
var _bloom = clamp(g.crt_bloom, 0, 100) / 100;
var _bl_tex = -1;
if (_bloom > 0) {
	var _bw = max(2, _aw div 2), _bh = max(2, _ah div 2);
	if (!surface_exists(bright) || surface_get_width(bright) != _bw
	|| surface_get_height(bright) != _bh) {
		if (surface_exists(bright)) surface_free(bright);
		bright = surface_create(_bw, _bh, bloom_fmt);
	}
	if (surface_exists(bright)) {
		gpu_set_tex_filter(true);
		surface_set_target(bright);
		draw_clear_alpha(c_black, 1);
		draw_surface_ext(application_surface, 0, 0, _bw / _aw, _bh / _ah, 0, c_white, 1);
		gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
		draw_surface_ext(application_surface, 0, 0, _bw / _aw, _bh / _ah, 0, c_white, 1);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		gpu_set_tex_filter(false);
		_bl_tex = __bloom_run(bright);
	}
	if (_bl_tex < 0) _bloom = 0;
}
if (u_blur_s < 0) _bloom = 0;

// ---- and draw it back through the tube ----
// the bulge and the chroma split resample, so the filter is on for the
// pass; at curvature 0 and chroma 0 every sample lands on a texel
// centre and the picture is exact. Blend, colour and alpha are set
// explicitly: a fullscreen quad inherits whatever the last drawer
// left, and a stray tint or additive mode here is the whole screen
gpu_set_blendmode(bm_normal);
gpu_set_tex_filter(true);
shader_set(sh_crt);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_res"), _aw, _ah);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_room"), room_width, room_height);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_time"), t);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_curve"),  clamp(g.crt_curve,  0, 100) / 100);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_scan"),   clamp(g.crt_scan,   0, 100) / 100);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_grille"), clamp(g.crt_grille, 0, 100) / 100);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_chroma"), clamp(g.crt_chroma, 0, 100) / 100);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_vig"),    clamp(g.crt_vig,    0, 100) / 100);
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_roll"),   g.crt_roll ? 1 : 0);
// the chain's sum peaks near CRT_BLOOM_STEPS x the source, so the
// strength is per level
shader_set_uniform_f(shader_get_uniform(sh_crt, "u_bloom"),  _bloom * 1.0 / CRT_BLOOM_STEPS);
if (_bloom > 0) {
	texture_set_stage(u_blur_s, surface_get_texture(_bl_tex));
	gpu_set_tex_filter_ext(u_blur_s, true);   // the blur is a small surface: read it smooth
	gpu_set_tex_repeat_ext(u_blur_s, false);
}
draw_surface_ext(scratch, 0, 0, room_width / _aw, room_height / _ah, 0, c_white, 1);
shader_reset();
gpu_set_tex_filter(false);
