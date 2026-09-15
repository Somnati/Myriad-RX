/// @description page_blit(surf, x, y) - a page surface to the screen through THE ONE DITHER (sh_page_out), under the ui fade
/// The only quantisation a float page meets: FILM GRAIN - white noise,
/// triangular, PAGE_GRAIN levels either way, on the render's pixel cells
/// (px_size room px, in window pixels), fresh every frame - exact black
/// stays black. On an 8-bit page the layers dithered themselves; this adds a
/// hair on top, which is harmless.
function page_blit(_surf, _x, _y) {
	static _u = undefined;
	if (is_undefined(_u)) _u = { time : shader_get_uniform(sh_page_out, "u_time"), cell : shader_get_uniform(sh_page_out, "u_cell"), amp : shader_get_uniform(sh_page_out, "u_amp"), mode : shader_get_uniform(sh_page_out, "u_mode"), levels : shader_get_uniform(sh_page_out, "u_levels") };
	if (!surface_exists(_surf)) return;
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	var _sc = surface_get_width(application_surface) / max(1, room_width);   // window px a room px
	shader_set(sh_page_out);
	shader_set_uniform_f(_u.time, (current_time mod 100000) / 1000);
	shader_set_uniform_f(_u.cell, max(1, planet_config().px_size) * _sc);
	shader_set_uniform_f(_u.amp, page_float() ? PAGE_GRAIN : PAGE_GRAIN * .5);
	// the look (settings > visuals > page dither): ordered / retro / chunky / grain
	var _pd = variable_global_exists("page_dither") ? g.page_dither : "ordered";
	shader_set_uniform_f(_u.mode, (_pd == "grain") ? 0 : 1);
	shader_set_uniform_f(_u.levels, (_pd == "retro") ? 15 : ((_pd == "chunky") ? 7 : 255));
	draw_surface_ext(_surf, _x, _y, 1, 1, 0, c_white, _fa);
	shader_reset();
	ui_fade_set(_fa);
}
