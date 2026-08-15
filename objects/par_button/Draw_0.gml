



draw_sprite_ext(sprite_index,0,x,y,1,1,0,c_back,1);
draw_sprite_ext(sprite_index,1,x,y,1,1,0,c_front,1);

draw_set_color(c_text);
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x+swdiv,y+shdiv,text);

draw_set_valign(fa_top);
