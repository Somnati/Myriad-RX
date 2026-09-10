// THE HOVER (his ask, 2026-09-10): the window chrome lights when the
// pointer is over it - red: the one that ends things - eased in and out
// rather than snapped, through the arbitrated mouse_over so a button
// under a dropdown or the menu does not light through it.
hov = trickle(hov, mouse_over() ? 1 : 0, 3, 0);
draw_sprite_ext(sprite_index, img, x, y, 1, 1, 0, merge_colour(cc, c_hred, hov), 1);
