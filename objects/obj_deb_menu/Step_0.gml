
tic -= 1*delta;

active = false;
if in_room(rm_id) active = true;

alpha = move_to(alpha,1,3);




//colb = make_colour_hsv(c_hue(col),c_sat(col),clamp(c_val(col),100,150));
tcol = col;
tcol = make_colour_hsv(c_hue(col),c_sat(col),255);
if active = true tcol = merge_color(tcol,c_white,.5);
bcol = merge_color(col,c_black,.5);


if visible = true
	if active = false
	if mouse_over()
		if mouse_check_button_pressed(mb_left)
		if tic <= 0{tic = tic_;
		if rm_id != -1 goto_room(rm_id);
		play_sound_ext(snd_matclick,.8,1.2,.3,1);
		}
		
		
if par_obj != -1{
	if instance_exists(par_obj) open = par_obj.open;
	if open = true{x = move_to(x,(room_width-sprite_width)+20-xoff,3);}
	if open = false{x = move_to(x,room_width+10+xoff,3);
		if x > room_width {kill;}
	}
}