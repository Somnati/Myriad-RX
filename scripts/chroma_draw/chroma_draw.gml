/// @description chroma_draw(x, y, r, col, seed, [fade], [cam]) - THE CHROMATIC STAR: its light will not hold together - the star drawn three times through the colour-write mask, red shifted one way and blue the other (the aberration), the shift turning slowly with a jitter, and a spectral halo turning against it (q267)
function chroma_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined) {
	if (_r < .5 || _fade <= 0) return;
	var _t = current_time / 1000;
	var _sh = max(1, _r * .10) * (1 + .35 * sin(_t * 2.3 + _seed)) + .6 * sin(_t * 9.1 + _seed * 3);   // (the split's reach, breathing and jittering)
	var _a = _t * 17 + (_seed mod 360);
	var _dx = dcos(_a) * _sh, _dy = -dsin(_a) * _sh;
	gpu_set_colorwriteenable(true, false, false, true);  star_draw(_x + _dx, _y + _dy, _r, _col, _seed, _fade, _cam);
	gpu_set_colorwriteenable(false, true, false, true);  star_draw(_x, _y, _r, _col, _seed, _fade, _cam);
	gpu_set_colorwriteenable(false, false, true, true);  star_draw(_x - _dx, _y - _dy, _r, _col, _seed, _fade, _cam);
	gpu_set_colorwriteenable(true, true, true, true);
	// the spectral halo: six soft glows on a ring, the spectrum round it, turning the other way
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	static _spec = [ rgb(255, 60, 60), rgb(255, 180, 40), rgb(120, 255, 90), rgb(60, 220, 255), rgb(90, 90, 255), rgb(220, 80, 255) ];
	gpu_set_blendmode(bm_add);
	for (var _k = 0; _k < 6; _k++) {
		var _ak = _k * 60 - _t * 11 + (_seed mod 360), _rk = _r * 2.0;
		draw_sprite_ext(spr_vis_glow_soft, 0, _x + dcos(_ak) * _rk, _y - dsin(_ak) * _rk, _r * 2.2 / _gw, _r * 2.2 / _gh, 0, _spec[_k], .10 * _fade);
	}
	gpu_set_blendmode(bm_normal);
}
