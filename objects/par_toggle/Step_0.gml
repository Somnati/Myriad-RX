
//sprite
p = (xx-x0)/(x1-x0);
adj = lerp(3,1.5,p);
if input = 0 xx = move_to(xx,x0,adj);
if input = 1 xx = move_to(xx,x1,adj);



cc = merge_colour(c0,c1,p);
aa = lerp(a0,a1,p);

    clicked = false; tic -= 1*delta;
    if mouse_over()
    if mouse_check_button_pressed(mb_left)
        if tic <= 0{clicked = true;

    switch input {
    case 0: {input = 1; play_sound_ext(snd_matclick2,1.15,1.5,.6,1); break;}
    case 1: {input = 0; play_sound_ext(snd_matclick,1.15,1.5,.3,1); break;}
    }

}

