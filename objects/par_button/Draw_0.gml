



draw_sprite_ext(sprite_index,0,x,y,1,1,0,c_back,1);
draw_sprite_ext(sprite_index,1,x,y,1,1,0,c_front,1);

draw_set_color(c_text);
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x+swdiv,y+shdiv,text);

draw_set_valign(fa_top);

// GM's draw state is GLOBAL and persists past this event: this object
// is the PARENT of every button, so a halign left at fa_center leaked
// into whatever drew next. valign was already restored below; halign
// was not.
draw_set_halign(fa_left);
