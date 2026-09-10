/// @description the pointer

// mobile has no pointer to draw, and drawing one at the last touch
// position leaves an arrow stranded on screen after the finger lifts
if (os_type == os_android || os_type == os_ios) exit;

// squashed: wider and shorter by the same amount, about the tip
draw_sprite_ext(spr_cursor, 0, mousex, mousey, 1 + sq, max(.3, 1 - sq), 0, c_white, 1);
