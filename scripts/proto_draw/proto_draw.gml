/// @description proto_draw(x, y, r, col, seed, [fade], [cam], [disc]) - A PROTOSTAR's ornament over its star (star_draw goes first): a thick warm HAZE round it (the birth cloud it still sits in) and, with disc = true (the system view), its DUST DISC - a flat ring of grain in the orbital plane from four to fourteen radii out, denser inward, turning slowly; additive (q253)
function proto_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined, _disc = false, _proj = undefined) {
	if (_r < .5 || _fade <= 0) return;
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	var _hc = merge_colour(_col, rgb(255, 170, 110), .5), _t = current_time / 1000;
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 9 / _gw, _r * 9 / _gh, 0, merge_colour(_hc, c_black, .35), .30 * _fade);
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 4 / _gw, _r * 4 / _gh, 0, _hc, .40 * _fade);
	if (_disc && is_method(_proj)) {
		// the disc: grains on the plane, hashed places, drifting round on the clock; denser and warmer inward
		for (var _k = 0; _k < 260; _k++) {
			var _hk = hash_mix(_seed + _k, 4711);
			var _rad = 4 + 10 * power((_hk mod 1000) / 1000, 1.6), _ang = ((_hk div 1000) mod 3600) / 10 + _t * (18 / _rad);
			var _pw = _proj(dcos(_ang) * _rad * _r, 0, dsin(_ang) * _rad * _r);
			if (is_undefined(_pw)) continue;
			var _dk = clamp(1 - (_rad - 4) / 10, 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_pw[0]), floor(_pw[1]), 1, 1, 0, merge_colour(_hc, rgb(120, 90, 80), 1 - _dk), (.25 + .55 * _dk) * _fade);
		}
	}
	gpu_set_blendmode(bm_normal);
}
