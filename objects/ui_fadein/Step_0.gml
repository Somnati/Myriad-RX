alpha = move_to(alpha,0,50);
if alpha <= 0 kill;

if mouse_check_button_pressed(mb_left) if alpha > 1 alpha = 1;

