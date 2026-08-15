
if (alpha <= 0) exit;

var _on = pill.enabled && pill.can_toggle;
var _c  = _on ? pill.color_on  : pill.color_off;
var _tc = _on ? pill.tcolor_on : pill.tcolor_off;

// pick flash: saturation + value lift toward white, decaying in step
if (glow > 0) {
	var _hu = colour_get_hue(_c);
	var _sa = colour_get_saturation(_c);
	var _va = colour_get_value(_c);
	_c = make_colour_hsv(_hu,
		lerp(_sa, min(_sa * 1.3, 255), glow),
		lerp(_va, 255, glow));
}

// the capsule: pixel stretch + the dial endcap sprites
draw_sprite_ext(spr_pixel_1x1, 0, x, y, w, h, 0, _c, alpha);
draw_sprite_ext(spr_dial_endcaps, 0, x - 3, y, 1, 1, 0, _c, alpha);
draw_sprite_ext(spr_dial_endcaps, 1, x + w, y, 1, 1, 0, _c, alpha);

draw_set_font(fnt);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_tc);
draw_set_alpha(clamp((alpha - .2) * 1.3, 0, 1));

// the lit pill wears the > name < marquee, breathing once a second
var _txt = pill.name;
if (_on) {
	if ((current_time div 1000) & 1) _txt = "> "  + _txt + " <";
	else                             _txt = ">  " + _txt + "  <";
}
draw_text(x + w * .5, y + h * .5, _txt);

draw_set_valign(fa_top);
draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
