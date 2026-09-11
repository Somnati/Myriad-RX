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
draw_surface_ext(scratch, 0, 0, room_width / _aw, room_height / _ah, 0, c_white, 1);
shader_reset();
gpu_set_tex_filter(false);
