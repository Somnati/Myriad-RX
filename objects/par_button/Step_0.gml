


click_tic -= 1*delta;
if click_tic > click_tic_ click_tic = 0;
click_tic = clamp(click_tic,0,click_tic_);
// (menu/dialogue blocking moved into syst_input: mouse_over() is
// arbitrated now, so a blocked button simply never sees the cursor)

if click_tic <= click_tic_{
c_front = merge_color(c_front_base,c_front_hl,click_tic/click_tic_);
c_back = merge_color(c_back_base,c_back_hl,click_tic/click_tic_);
}

