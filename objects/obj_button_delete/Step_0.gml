
pair;

if click_tic <= 0
if mouse_over()
	if mouse_check_button_pressed(mb_left){
		click_tic = click_tic_;
		
		if file_exists(syst_handle_save.file_to_handle) file_delete(syst_handle_save.file_to_handle);
		
	}