/// @description dwarf_draw(x, y, r, col, [fade]) - a WHITE DWARF's blaze over its star (star_draw goes first): tiny, but fierce - a hard white core, a wide blue-white bloom and the horizontal line bloom the galactic map gives it
/// His ask (2026-09-17): "they need to be brighter when viewed in system
/// view if I'm at a white dwarf". Additive; the line is the dwarf's mark
/// everywhere (the map, the skies' neighbours, and here)
function dwarf_draw(_x, _y, _r, _col, _fade = 1) {
	if (_r < .5 || _fade <= 0) return;
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	var _dc = merge_colour(_col, c_white, .6);
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 7 / _gw, _r * 7 / _gh, 0, _dc, .55 * _fade);            // the bloom
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 22 / _gw, max(1, _r * .9) / _gh, 0, _dc, .60 * _fade);   // the line
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 2.6 / _gw, _r * 2.6 / _gh, 0, c_white, .80 * _fade);     // the core
	gpu_set_blendmode(bm_normal);
}
