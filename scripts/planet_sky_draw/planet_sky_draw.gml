/// @description planet_sky_draw(seed, x, y, w, h) - a star field behind
/// a world: a hundred hashed stars in the rectangle, a few brighter
/// with a soft glow, all twinkling a little on their own clocks. Seeded
/// by the world, so the same sky returns with the same world.
function planet_sky_draw(_seed, _x, _y, _w, _h) {
	var _rs = random_get_seed();
	random_set_seed((_seed ^ 917) & $7fffffff);
	var _t = current_time / 1000;
	repeat (110) {
		var _sx = _x + random(_w), _sy = _y + random(_h);
		var _big = (random(1) < .12);
		var _ph = random(1000);
		var _tw = .55 + .45 * abs(dsin((_t * (40 + random(40)) + _ph) * 6));
		var _col = choose(c_white, c_white, rgb(200, 215, 255), rgb(255, 230, 200));
		if (_big) {
			var _gs = (6 + random(4)) / max(1, sprite_get_width(spr_vis_glow_soft));
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(spr_vis_glow_soft, 0, _sx, _sy, _gs, _gs, 0, _col, .25 * _tw);
			gpu_set_blendmode(bm_normal);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), floor(_sy), 1, 1, 0, _col, .95 * _tw);
		} else
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), floor(_sy), 1, 1, 0, _col, (.25 + .5 * random(1)) * _tw);
	}
	rng_release(_rs);
}
