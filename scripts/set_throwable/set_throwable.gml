/// @description ability_name(val);
/// @param val
function set_throwable(){

	_aa_ = mouse_x; _bb_ = mouse_y;
	if is_object(system) {_aa_ = display_mouse_get_x(); _bb_ = display_mouse_get_y();}
	_dmx = _aa_
	_dmy = _bb_
	
	_ws_ = false;
	_wmove_gate = 0; // window-move throttle accumulator
	
	_whspd = 0;
	_wvspd = 0;
	_spd = 0; _spd_add = 0;
	_pwrx = 0;
	_pwry = 0;
	_dir = 0;
	_wrx = 0; fx = 0;
	_wry = 0; fy = 0;
	_gosx = 0; _gosy = 0;
	_stun = 0;
	_center_x = window_get_x()+(window_get_width()/2);
	_center_y = window_get_y()+(window_get_height()/2);
	_has_snap = 0; _phas_snap = 0;
	_snapping = false;
	_readytolaunch = false;
	p_readytolaunch = _readytolaunch;
	_endonbounce = false;
	_bounceresist = 0;
	_bounceresist_ = 0;
	_tminus = 0;
	cur_bounces = 0;
	_selected = false;
	_cangrab = true;
	_org_to_dm = 0;
	_do_bounces = false;
	_do_slide = false;
	
_snd_ = snd_click;
	

dgx = 0;
dgy = 0;
dgz = 0;

}