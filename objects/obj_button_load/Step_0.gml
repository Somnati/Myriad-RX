
pair;

if click_tic <= 0
if mouse_over()
	if mouse_check_button_pressed(mb_left){
		click_tic = click_tic_;
		
		syst_handle_save.action = sv_load;
		
	}