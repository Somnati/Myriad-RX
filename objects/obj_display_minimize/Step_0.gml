// persistent window chrome: pin to the current room's top-right, ride
// just above the header when the room has one
x = room_width - 48;
y = 0;
depth = instance_exists(obj_ui_header) ? obj_ui_header.depth - 5 : -1005;

input = false;

pair

if input = true {
	syst_display.minimize = true;
   //window_set_position(window_get_x(),display_get_height()); 
	//window_minimise();
	//show("window_size = " + string(window_get_width()));
}


	





