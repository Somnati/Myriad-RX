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
	show("[surface] crt scratch rebuilt at " + string(current_time));   // (the flicker hunt, 2026-09-13)
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

// ---- and draw it back through the tube ----
// the bulge and the chroma split resample, so the filter is on for the
// pass; at curvature 0 and chroma 0 every sample lands on a texel
// centre and the picture is exact. Blend, colour and alpha are set
// explicitly: a fullscreen quad inherits whatever the last drawer
// left, and a stray tint or additive mode here is the whole screen
gpu_set_blendmode(bm_normal);
gpu_set_tex_filter(true);
shader_set(sh_crt);
// (the shader's handles looked up once - nine string searches a frame before; q222)
if (!variable_instance_exists(id, "crt_u")) crt_u = { chroma : shader_get_uniform(sh_crt, "u_chroma"), curve : shader_get_uniform(sh_crt, "u_curve"), grille : shader_get_uniform(sh_crt, "u_grille"), res : shader_get_uniform(sh_crt, "u_res"), roll : shader_get_uniform(sh_crt, "u_roll"), room : shader_get_uniform(sh_crt, "u_room"), scan : shader_get_uniform(sh_crt, "u_scan"), time : shader_get_uniform(sh_crt, "u_time"), vig : shader_get_uniform(sh_crt, "u_vig") };
shader_set_uniform_f(crt_u.res, _aw, _ah);
shader_set_uniform_f(crt_u.room, room_width, room_height);
shader_set_uniform_f(crt_u.time, t);
shader_set_uniform_f(crt_u.curve,  clamp(g.crt_curve,  0, 100) / 100);
shader_set_uniform_f(crt_u.scan,   clamp(g.crt_scan,   0, 100) / 100);
shader_set_uniform_f(crt_u.grille, clamp(g.crt_grille, 0, 100) / 100);
shader_set_uniform_f(crt_u.chroma, clamp(g.crt_chroma, 0, 100) / 100);
shader_set_uniform_f(crt_u.vig,    clamp(g.crt_vig,    0, 100) / 100);
shader_set_uniform_f(crt_u.roll,   g.crt_roll ? 1 : 0);
draw_surface_ext(scratch, 0, 0, room_width / _aw, room_height / _ah, 0, c_white, 1);
shader_reset();

// ---- the bloom, over the tube ----
// The chain's top link (the summed halo, under 2 at its brightest)
// added onto the finished picture: bm_add is src x alpha + dst, so the
// slider IS the alpha - .5 x it, which at the default 25% lays a
// white line's halo on at an eighth. Through sh_fog_dither (the
// house IGN, luminance-gated and alpha-compensated) so the tail lands
// in 8-bit without rings. It is not put through the bulge: a soft
// glow a couple of px off its source is a soft glow.
if (_bloom > 0) {
	gpu_set_blendmode(bm_add);
	shader_set(sh_fog_dither);
	shader_set_uniform_f(dith_u_time, t);
	draw_surface_ext(_bl_tex, 0, 0,
		room_width / surface_get_width(_bl_tex), room_height / surface_get_height(_bl_tex),
		0, c_white, _bloom * .5);
	shader_reset();
	gpu_set_blendmode(bm_normal);
}
gpu_set_tex_filter(false);
