/// @description ex_galaxy_init() - THE GALAXY VIEW (the star map) of syst_exped_panel: its state and its methods, defined on the panel (self = the panel; called from its Create). q218, the deconvolution: gx_* the state, __gx_* / the bloom its methods
function ex_galaxy_init() {
// ---- THE GALAXY VIEW (the star map, 2026-09-15: the tech demo's rm_starmap as a page) ----
gx_x = 0; gx_y = 0; gx_zoom = 1; gx_init = false;   // the camera's top-left on the plane, the zoom; centred on the home star the first time
gx_press = false; gx_px = 0; gx_py = 0; gx_cx0 = 0; gx_cy0 = 0; gx_travel = 0;
gx_sel = -1; gx_sys = undefined;     // the tapped star and its system
gx_from = "planet";                  // where [back] returns
gx_mm = -1; gx_mm_seed = -1;         // THE MINIMAP (his ask: bring it back): the star dots baked once, 80px wide
gx_glow_a = -1; gx_glow_b = -1;      // the bloom's two half-size passes (sh_blur)
/// the bloom: the finished map (src, w x h) blurred at half size, two
/// passes, laid back over the target additively at alpha a
// THE BLOOM composites INTO the page (2026-09-15): float all the way, so
// the halos meet 8-bit only at the page's blit (x / y are kept for the
// 8-bit path, where it still lands on the screen)
__bloom = function(_src, _w, _h, _x, _y, _a, _ds = 1, _into = false) {   // (_into: back into the source whatever the page - the skies, 2026-09-16)   // (ds: the draw scale on the page - the map's surface is drawn gs times over, 2026-09-16)
	var _hw = max(2, floor(_w * .5 * _ds)), _hh = max(2, floor(_h * .5 * _ds));   // (half the ROOM's size: a denser source blurs the same width)
	if (!surface_exists(gx_glow_a) || surface_get_width(gx_glow_a) != _hw || surface_get_height(gx_glow_a) != _hh) { if (surface_exists(gx_glow_a)) surface_free(gx_glow_a); gx_glow_a = page_surface(_hw, _hh); }
	if (!surface_exists(gx_glow_b) || surface_get_width(gx_glow_b) != _hw || surface_get_height(gx_glow_b) != _hh) { if (surface_exists(gx_glow_b)) surface_free(gx_glow_b); gx_glow_b = page_surface(_hw, _hh); }
	static _u = undefined;
	if (is_undefined(_u)) _u = { dir : shader_get_uniform(sh_blur, "u_dir"), texel : shader_get_uniform(sh_blur, "u_texel") };
	var _ftf = gpu_get_tex_filter();
	gpu_set_tex_filter(true);
	gpu_set_blendmode(bm_normal);
	surface_set_target(gx_glow_a);
	draw_clear_alpha(c_black, 1);
	shader_set(sh_blur);
	shader_set_uniform_f(_u.dir, 1, 0); shader_set_uniform_f(_u.texel, 1 / (_w * _ds), 1 / (_h * _ds));
	draw_surface_ext(_src, 0, 0, _hw / _w, _hh / _h, 0, c_white, 1);
	shader_reset();
	surface_reset_target();
	surface_set_target(gx_glow_b);
	draw_clear_alpha(c_black, 1);
	shader_set(sh_blur);
	shader_set_uniform_f(_u.dir, 0, 1); shader_set_uniform_f(_u.texel, 1 / _hw, 1 / _hh);
	draw_surface(gx_glow_a, 0, 0);
	shader_reset();
	surface_reset_target();
	gpu_set_blendmode(bm_add);
	if (page_float() || _into) { surface_set_target(_src); draw_surface_ext(gx_glow_b, 0, 0, _w / _hw, _h / _hh, 0, c_white, _a); surface_reset_target(); }
	else draw_surface_ext(gx_glow_b, _x, _y, _w * _ds / _hw, _h * _ds / _hh, 0, c_white, _a);
	gpu_set_blendmode(bm_normal);
	gpu_set_tex_filter(_ftf);
};
__gx_mm_r = function() { var _sm = starmap_get(); var _w = 80; return { x : land ? 14 : 4, y : list_y + 34, w : _w, h : ceil(_sm.height * _w / _sm.width) }; };
gx_para = [];                        // the parallax backdrop's layers (built on the first draw)
__gx_r = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };
__gx_enter_r = function() { return { x : room_width - (land ? 14 : 4) - 80, y : room_height - 8 - 16, w : 80, h : 16 }; };   // [enter] the tapped star's system (bottom right, the demo's seat)
}
