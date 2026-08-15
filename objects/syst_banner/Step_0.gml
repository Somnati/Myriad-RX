
visible = true;
depth = 0;

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

y = move_to(y,desy,4);        

//if keyboard_check_pressed(vk_space) assign_banner("item acquired");




