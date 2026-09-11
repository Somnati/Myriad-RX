if (alpha <= .01) exit;
if (!instance_exists(obj_puck)) exit;
var _o = obj_puck;
var _mx = max(room_width, room_height);   // the puck's speed scale (its _max)
var _h = 7;
var _f = 0;

draw_set_alpha(alpha);

// ---- bounces, the number in the large outline font, tier-coloured, popping ----
draw_set_font(fnt_outline);
if (str_w == -1) str_w = string_width("bounces ");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(x + xos, y + _h * _f, "bounces ");
draw_set_font(fnt_large_outline);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(vis_tier_color(max(1, bnc)));
draw_text_transformed(x + xos + str_w + 4 + (string_width(string(bnc)) * .5) * text_size,
	y + _h * _f + 3, string(bnc), text_size, text_size, 0);
draw_set_valign(fa_top);
draw_set_halign(fa_left);
draw_set_font(fnt_outline);
_f++;

// ---- the throw's profit ----
draw_set_color(g.profit_color);
draw_text(x + xos, y + _h * _f, "profit " + draw_profit);
_f++;

// ---- the live speed, aqua through red ----
var _fs = clamp(_o.spd / _mx, 0, 1);
draw_set_color(merge_colour(c_aqua, c_hred, _fs));
var _sp = _o.spd;
if (_sp >= 100) _sp = floor(_sp);
draw_text(x + xos, y + _h * _f, "spd " + string_format(_sp, 1, (_sp >= 100) ? 0 : 1));

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt);
