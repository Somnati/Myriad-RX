/// @description the pointer

// mobile has no pointer to draw, and drawing one at the last touch
// position leaves an arrow stranded on screen after the finger lifts
if (os_type == os_android || os_type == os_ios) exit;

draw_sprite_ext(spr_cursor, 0, mousex, mousey, 1, 1, 0, c_white, 1);
