

// BUTTON BOUNDS
x1 = xx-1;
y1 = y-1;
x2 = x1+ww+1;
y2 = y1+ww+1;

// IF NOT GRABBED
if grabbed = false{
	abar = move_to(abar,.6,4);
}

// NO CLICK
if grabbed = true
	if not mouse_check_button(mb_left) {
		grabbed = false;
		xdrag = 0;
		play_sound_ext(snd_matclick,.9,1.2,.3,1);
}
	
// IF CLICKED
if mouse_over_ext(x1,y1,x2,y2)
	if mouse_check_button_pressed(mb_left){
		grabbed = true;
		mxos = mouse_x-(xx+(ww/2));
		play_sound_ext(snd_matclick,.4,.6,.3,1);
}

img = 1;
// IF GRABBED
if grabbed = true{
	abar = move_to(abar,1,3);
	xdrag += point_distance(mouse_x_prev,mouse_y_prev,mouse_x,mouse_y);
	img = 2;
	
	// MOVE BUTTON
	if xdrag > 1{
	desx = mouse_x-(ww/2)-mxos;
	if mouse_x < xmin+7 desx = min(xmin,desx);
	if mouse_x > xmax-7+ww desx = max(xmax,desx);
		xx = move_to(xx,desx,4);
	}

	// BUTTON LIMITS
	if xx > xmax xx = xmax;
	if xx < xmin xx = xmin;

}

// CALC VALUE
p = (xx-xmin)/(xmax-xmin);
val = round(lerp(vmin,vmax,p));



// HITS EDGES
if pval != val if pval != -1{
	if val = vmin 
	or val = vmax {
	play_sound_ext(snd_matclick2,.8,1.2,.3,1);
	}
	
}


pval = val;