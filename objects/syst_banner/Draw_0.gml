
draw_set_font(fnt);
draw_set_halign(fa_left);


l = 0; h = 9;

mx_w = 0;


repeat lines{

//draw_pixel(room_width/2,y_[l],room_width/2,1,c_hred,1);
if alpha[l] > 0 
	if text[l] != "$$$"{
	//draw_pixel(x+dx[l]-w[l],dy[l]+y,w[l],h,c_back[l],alpha[l]*.8);
	c_bck = merge_colour(c_back[l],c_black,.6);
	draw_sprite_color(spr_pixel_1x1,0,x+dx[l]-w[l],dy[l]+y,0,0,1,1,w[l],h,0,c_bck,c_black,c_bck,c_black,alpha[l]*.9)

draw_sprite_ext(spr_banner_endcap,0,x+dx[l],dy[l]+y,1,1,0,c_black,alpha[l]*.9);

// the little leading tick. Its alpha was hardcoded to 1 while every
// other part of the line rides alpha[l], so it hung in the air at full
// strength after the banner had faded out from under it (his report
// 2026-09-06).
draw_sprite_ext(spr_pixel_1x1,0,x+dx[l]-w[l],dy[l]+y+(h/2),3,1,0,c_text[l],alpha[l]);

draw_set_alpha(alpha[l]);
draw_set_color(c_text[l]);
draw_text_transformed(x+dx[l]-w[l]+5,dy[l]+2+y,string_hash_to_newline(text[l]),.8,.8,0);

if mx_w < w[l] mx_w = w[l];
draw_sprite_ext(spr_pixel_1x1,-1,x+dx[l]-w[l],dy[l]+y,w[l],h,0,c_white,glow[l]*alpha[l]);}

l++;}

x1 = -(mx_w+5)

// the loop leaves draw_set_alpha at the last line's fade value -
// everything drawn after the banner inherited it (his round-2 report:
// beans faded randomly). reset before handing the pipeline on.
draw_set_alpha(1);