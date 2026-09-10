// every alpha rides image_alpha: the settings screen hands each widget
// its row's fade (the chaperone in syst_settings' Step), and a paddle
// that ignored it popped in at full strength while its row was still
// arriving - and vanished a beat before the row did on the way out
// (his report, 2026-09-10: the screen "snaps before it settles").
// Nothing else sets image_alpha, so everywhere else this is x1.
var _ia = image_alpha;

//paddle
draw_sprite_ext(sprite_index,0,x,y,1,1,0,c_black,_ia);
draw_sprite_ext(sprite_index,0,x,y,1,1,0,c0,a0*_ia);
draw_sprite_part_ext(sprite_index,0,0,0,xx+2,sprite_height,x,y,1,1,c1,a1*_ia);

//ball
draw_sprite_ext(sprite_index,1,x+xx,y,1,1,0,c,_ia);