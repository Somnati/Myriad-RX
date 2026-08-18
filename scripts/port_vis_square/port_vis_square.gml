/// port_vis_square (techdemo II port - PRIVATE copy: myriad's own
/// vis_square is the old cube visualizer's internal and stays untouched)
/// Pure draw function: one small unit square. Takes fully-resolved
/// position, scale, color, and alpha. No zoom math, no branching.
/// Assumes the sprite is 1x1 px (spr_pixel_1x1 style).

function port_vis_square(_spr, _x, _y, _unit, _col, _alpha) {
    draw_sprite_ext(_spr, 0, _x, _y, _unit, _unit, 0, _col, _alpha);
}
