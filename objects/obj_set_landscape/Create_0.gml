

// re-arm the swap with the PLAYER'S chosen size (this used to hardcode
// -2560, so every landscape room silently reset the resolution choice)
g.screen_size = -abs(g.screen_size_user);
display_set_gui_size(room_width,room_height);
/*
window_set_size(display_get_width(),display_get_height());
window_set_position(0,0);
surface_resize(application_surface,window_get_width(),window_get_height());
display_set_gui_size(room_width,room_height);