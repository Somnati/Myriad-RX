

// two transitions, one owner. the latched kind picks the painter:
// slice slats or the classic circle; balpha (the circle's post-switch
// fade) draws for both but only the circle path ever raises it.

if (trans_active_kind == 1) {
	if (slice_phase > 0) {
		var _sh2 = ceil(room_height / slice_n);
		for (var _i = 0; _i < slice_n; _i++) {
			var _p = clamp((slice_t - _i * slice_stag) / slice_dur, 0, 1);
			var _sy = _i * _sh2;
			if (slice_phase == 1) {
				// COVER: ease-in - the slat builds speed and slams shut.
				// even slats enter left->right, odd right->left; the 1px
				// slate accent rides the leading edge and melts into the
				// slam
				var _e = _p * _p * _p;
				var _w2 = _e * room_width;
				if (_w2 <= 0) continue;
				if (_i & 1) {
					draw_sprite_ext(spr_pixel_1x1, 0, room_width - _w2, _sy,
						_w2, _sh2, 0, c_black, 1);
					draw_sprite_ext(spr_pixel_1x1, 0, floor(room_width - _w2), _sy,
						1, _sh2, 0, sett_ink, .5 * (1 - _e));
				} else {
					draw_sprite_ext(spr_pixel_1x1, 0, 0, _sy, _w2, _sh2, 0,
						c_black, 1);
					draw_sprite_ext(spr_pixel_1x1, 0, floor(_w2) - 1, _sy,
						1, _sh2, 0, sett_ink, .5 * (1 - _e));
				}
			} else {
				// REVEAL: ease-out - the same slats keep flying the SAME
				// direction (even onward rightward, odd leftward), black
				// shrinking behind the moving edge; the accent pops at
				// full cover and fades as it sweeps
				var _e = 1 - power(1 - _p, 3);
				var _w2 = (1 - _e) * room_width;
				if (_w2 <= 0) continue;
				if (_i & 1) {
					draw_sprite_ext(spr_pixel_1x1, 0, 0, _sy, _w2, _sh2, 0,
						c_black, 1);
					draw_sprite_ext(spr_pixel_1x1, 0, floor(_w2) - 1, _sy,
						1, _sh2, 0, sett_ink, .5 * (1 - _e));
				} else {
					draw_sprite_ext(spr_pixel_1x1, 0, room_width - _w2, _sy,
						_w2, _sh2, 0, c_black, 1);
					draw_sprite_ext(spr_pixel_1x1, 0, floor(room_width - _w2), _sy,
						1, _sh2, 0, sett_ink, .5 * (1 - _e));
				}
			}
		}
	}
}
else {
	draw_set_color(c_black);
	draw_set_alpha(alpha);
	draw_set_circle_precision(48);
	draw_circle(x,y,r,false);
}

draw_sprite_ext(spr_pixel_1x1,0,0,0,room_width,room_height,0,c_black,balpha);

// the wipe's alpha must not outlive the event - draw state carries
// across frames, and this is Draw END, so it would tint the next
// frame's first draws (syst_banner's 'beans faded randomly' class)
draw_set_alpha(1);
