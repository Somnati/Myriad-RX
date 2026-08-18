/// port_vis_line (techdemo II port - PRIVATE copy: myriad's own
/// vis_line is the old cube visualizer's internal and stays untouched)
/// Pure draw function: one full row of 10 units in a single draw call.
/// Takes fully-resolved position, scale, color, and alpha.
/// Assumes the sprite is 10x1 px (spr_line_10 style), so scaling both axes
/// by _unit yields a row 10 units wide and 1 unit tall.

function port_vis_line(_spr, _x, _y, _unit, _col, _alpha) {
    draw_sprite_ext(_spr, 0, _x, _y, _unit, _unit, 0, _col, _alpha);
}
