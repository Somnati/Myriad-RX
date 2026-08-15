


draw_sprite_ext(spr_pixel_1x1,0,xmin+1,y+(ww/2)-ceil(bh/2)+1,xmax-xmin+ww-1,bh,0,c0,abar);
if tfiller = true draw_sprite_ext(spr_pixel_1x1,0,xmin+1,y+(ww/2)-ceil(bh/2)+1,(xx-xmin)+(ww/2),bh,0,cbar,abar);

draw_sprite_ext(sprite_index,img,x1+1,y1+1,1,1,0,c1,1);

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
draw_text(xmax+ww+5,y+1,string(val));

//draw_set_color(c_pink);
//draw_rectangle(x1,y1,x2,y2,true)