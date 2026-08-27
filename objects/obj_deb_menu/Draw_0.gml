

//draw_sprite_ext(sprite_index,1,x,y,1,1,0,c_black,alpha*.6);

//gpu_set_blendmode(bm_add);

_alpha = .7;
if active = true _alpha = 1;
draw_sprite_ext(sprite_index,1,x,y,1,1,0,bcol,_alpha*lerp(.9,.5,(color_get_red(col)+color_get_green(col)+color_get_blue(col))/(255*3)));

//gpu_set_blendmode(bm_normal);

//outline
if active = true draw_sprite_ext(sprite_index,0,x+7,y,1,1,0,bcol,alpha);



draw_set_font(fnt);
draw_set_halign(fa_center);
draw_set_color(tcol);
draw_set_alpha(1);
draw_text_transformed(x+swdiv+10-14,y+3,name,1,1,0);

// restore the global draw state (see par_button)
draw_set_halign(fa_left);
