/// @description swell_draw(x, y, r, col, seed, [fade], [cam]) - THE SWELLING STAR: star_draw at the swell's size, and at the snap a flare - a hot ring thrown off the disc that widens and fades with the spring (q267)
function swell_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined) {
	if (_r < .5 || _fade <= 0) return;
	var _sw = star_swell(_seed);
	star_draw(_x, _y, _r * _sw.s, _col, _seed, _fade, _cam);
	if (_sw.flare > .02) {
		var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
		var _fc = merge_colour(_col, c_white, .5), _rr = _r * (1.3 + 1.6 * (1 - _sw.flare));
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _rr * 2.6 / _gw, _rr * 2.6 / _gh, 0, _fc, .45 * _sw.flare * _fade);
		draw_set_alpha(.7 * _sw.flare * _fade); draw_set_circle_precision(48); draw_circle_colour(_x, _y, _rr, _fc, _fc, true); draw_set_circle_precision(24); draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}
}
