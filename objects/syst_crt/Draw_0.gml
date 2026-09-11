if (!__on()) exit;
if (!surface_exists(application_surface)) exit;

// ---- capture what has drawn so far ----
var _aw = surface_get_width(application_surface);
var _ah = surface_get_height(application_surface);
if (!surface_exists(scratch) || surface_get_width(scratch) != _aw
|| surface_get_height(scratch) != _ah) {
	if (surface_exists(scratch)) surface_free(scratch);
	scratch = surface_create(_aw, _ah);
}
surface_copy(scratch, 0, 0, application_surface);
t += delta / 60;

// ---- and draw it back through the tube ----
// the bulge and the chroma split resample, so the filter is on for the
// pass; at curvature 0 and chroma 0 every sample lands on a texel
// centre and the picture is exact
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
draw_surface_stretched(scratch, 0, 0, room_width, room_height);
shader_reset();
gpu_set_tex_filter(false);
