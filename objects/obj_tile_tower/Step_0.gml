// it belongs to the tile room's open menu: either gone, it goes
if (!instance_exists(syst_tiles) || (!instance_exists(syst_menu2) && !instance_exists(obj_ui_menu2))) { instance_destroy(); exit; }
if (!instance_exists(syst_menu2)) { instance_destroy(); exit; }
if (room_width <= 300) { instance_destroy(); exit; }   // portrait has no left edge to spare

top_y = syst_tiles.board_top + 4;

// ---- the wheel walks the view a tier, only on the column ----
wheel_t = max(0, wheel_t - delta);
if (__hot() && wheel_t <= 0) {
	if (mouse_wheel_up())   { view_to += 1; wheel_t = 2; }
	if (mouse_wheel_down()) { view_to -= 1; wheel_t = 2; }
}
// clamped: never below tier 1 at the foot, never so high the beacon
// (the board's highest) leaves the bottom of the column
var _hi = max(1, g.tiles.highest);
view_to = clamp(view_to, 1, max(1, _hi));
view = move_to(view, view_to, 6);
if (abs(view - view_to) < .01) view = view_to;
