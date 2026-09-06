
if (!instance_exists(syst_menu2)) { kill; exit; }
var _a = syst_menu2.am;
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .48 * _a);

// THE EDGE GRADIENTS (his ask 2026-09-06). The techdemo's OLD menu
// backdrop drew these and menu v2 never picked them up - the sprite had
// not even been ported. spr_menu_back_3 is a 144x1 strip, opaque at
// column 0 and fading out by column 143: drawn twice with its single
// pixel row stretched to the room's full height, once inward from each
// side edge. The right-hand copy takes a NEGATIVE x scale anchored at
// room_width, which is what mirrors it.
// _s keeps each fade spanning HALF the room at any width - 144 is the
// portrait width, so the scale is 1 in rm_clicker and larger in the
// landscape twin, and neither has to know about the other.
var _s = room_width / 144;
draw_sprite_ext(spr_menu_back_3, 0, 0, 0, _s / 2, room_height, 0,
	c_black, .65 * _a);
draw_sprite_ext(spr_menu_back_3, 0, room_width, 0, -(_s / 2), room_height, 0,
	c_black, .65 * _a);
