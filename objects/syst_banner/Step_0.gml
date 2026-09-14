
visible = true;
// ABOVE THE SCREENS (his report: it was drawing behind the upgrades
// table). It sat at 0, which is the same depth every full-screen
// controller draws its rows at, so which one won was down to instance
// order. rm_clicker's plan is header -1000 / menu -520 / drawer -20, and
// a banner is a system message: over the menu, under the header.
depth = -540;

desx = 0;
x = move_to(x,desx,5);



lines = 15;

l = 0;
repeat lines{ 
if os_is_paused() free_banner(l);
if clear = true {free_banner(l); show("[clear banner]");}

    if text[l] != ""{

		hp[l] -= 1*delta;
        glow[l] = move_to(glow[l],0,4);
        
        if hp[l] > 0 alpha[l] = move_to(alpha[l],1,5);
        if l != lines-1 if hp[l] <= 0 alpha[l] = move_to(alpha[l],0,8);
        
        //last banner
        if l = lines-1{hp[l] = 0;
            alpha[l] = move_to(alpha[l],0,3);
        }
        
        //position
        draw_set_font(fnt);   // (measure in the banner's own font - whatever the last Step left set)
        w[l] = (string_width(string(text[l]))+15);
        dy[l] = move_to(dy[l],y_[l],5);
        dx[l] = move_to(dx[l],(string_width(string(text[l]))+15),5);
        
        //kill
        if hp[l] < 0 if alpha[l] <= 0{
        free_banner(l);
        }
    }
    

    
l++}//END REP

clear = false;

desy = ystart;
// UNDER THE OBJECTIVE CARD (his ask, 2026-09-13): the stack hangs from the
// top left, where the card lives - while the card is up the stack starts
// under it and rides its fold, so nothing lands on the checklist
if (instance_exists(syst_objectives) && syst_objectives.a > .05 && syst_objectives.okey != "") {
	var _cr = syst_objectives.__rect();
	desy = max(desy, _cr.y + _cr.h + 3);
}
y = move_to(y,desy,4);        

//if keyboard_check_pressed(vk_space) assign_banner("item acquired");




