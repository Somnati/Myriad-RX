/// @description do_throwable(x,y,dw,dh,ww,wh,dmx,dmy);
/// @param x
/// @param y
/// @param dw
/// @param dh
/// @param ww
/// @param wh
/// @param dmx
/// @param dmy
function do_throwable(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7){
	
	
	_pwrx = _wrx; _pwry = _wry;
	if _ws_ = false{_ws_ = true;
	_wrx = argument0; _wry = argument1;
	fx = _wrx; fy = _wry;
	}
	
	is_system = false; if is_object(syst_display) is_system = true;
	_dw = argument2
	_dh = argument3
	_ww = argument4
	_wh = argument5
	
	_pdmx = _dmx;
	_pdmy = _dmy;
	_dmx = argument6
	_dmy = argument7
	_bnd_x1 = 0; _bnd_x2 = _dw;
	if instance_exists(obj_ui_header) _bnd_y1 = obj_ui_header.sprite_height; _bnd_y2 = _dh;
	if is_system{
	//_bnd_x1 = 0 _bnd_x2 = _dw;
	//_bnd_y1 = -_wh*.8; _bnd_y2 = _dh+floor(_wh*.9)
	_bnd_x1 = -_dw; _bnd_x2 = _dw*2;
	_bnd_y1 = 0; _bnd_y2 = _dh*2;
	}
	//_gosx = (_ww*clamp(((_wrx+(_ww/2))/min(_dw,_bnd_x2)),0,1));
	//_gosy = _wh*(_dmy/_dh)
	//if is_system _gosy = (_wh*lerp(0,1,clamp(_wry/_dh,0,1)));
	


	
	_orgx = _wrx+_gosx;
	_orgy = _wry+_gosy;
	

	_org_to_dm = point_distance(_orgx,_orgy,_dmx,_dmy);
	
	
	_lx = (_dw/2)-(_ww/2);
	_ly = _dh-(_wh*.2);
			if _readytolaunch = true _dir = point_direction(_orgx,_orgy,_dmx,_dmy);
		
	
	
	
	_stun -= 1*delta;
	_os = .5;

	p_readytolaunch = _readytolaunch;


if _cangrab = true
if is_system and mouse_check_button_pressed(mb_right)
or not is_system and mouse_over() and mouse_check_button_pressed(mb_left){
	
	_gosx = window_mouse_get_x();
	_gosy = window_mouse_get_y();
	_wrx = window_get_x(); _wry = window_get_y();
	_orgx = _wrx+_gosx;
	_orgy = _wry+_gosy;

	//_cosx = _orgx;
	//_cosy = _orgy;
	//if _wry <= 1 _cosy = _dmy;
	//_org_to_dm_clamped = point_distance(_cosx,_cosy,clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2));

	_aa_ = _orgx;
	_bb_ = _orgy;
	_whspd = 0;
	_wvspd = 0;
	cur_bounces = 0;
	cur_profit = 0;
	highest_speed = 0;
	

	
	_spd = 0;
	_snapping = false;
	_readytolaunch = false;
	
	_endonbounce = false;
	_bounceresist = 0;
	_selected = true;
	
	_snd_ = snd_click
	

}
	_mxspd = max(_dw,_dh);
	_vv = (abs(_wvspd)+abs(_whspd));
	

	
	_cc = (max(_dw,_dh)/6); _cc = clamp(_vv/_cc,0,1); _stun_ = lerp(0,3,_cc*_cc); 
	_cc = (max(_dw,_dh)/6); _cc = clamp(_vv/_cc,0,1); _wfric = lerp(.99,.97,_cc);
	//if g.th_reducefriction = true _wfric = .99;
	
	__stun = power(_stun/max(_stun,_stun_),3);
	//if g.th_nohitstun = true __stun = 0;
	_lerp = point_distance(_orgx,_orgy,_dmx,_dmy)/(_dw*.05);
	_lerp = clamp(_lerp,1,2);
	
	_band = 1;
	
	

	







if _cangrab = true
if is_system and mouse_check_button(mb_right)
or not is_system and mouse_check_button(mb_left)
if _selected = true{


	
_tminus += 1*delta; if _readytolaunch = false _tminus = 0;


	_adj_ = 1; if _readytolaunch = true {if _tminus < 25 _adj_ *= 40; if _tminus >= 25 _adj_ /= 3;}
	if _snapping = false if not is_system _adj_ /= 5;
	if _snapping = false if _readytolaunch = false if _stun <= 0 if _org_to_dm > 200 _adj_ /= lerp(1,10,(_org_to_dm-200)/(max(_dw,_dh)-200));
	if _snapping = true _adj_ /= 100;
		_aa_ = trickle(_aa_,_dmx,_adj_*_lerp);
	_bb_ = trickle(_bb_,_dmy,_adj_*_lerp);
	
	_c_ = _aa_-_gosx;
	
	fx = _c_; fy = _bb_-_gosy;

	_cosx = _orgx;
	_cosy = _orgy;
	if _wry <= 1 _cosy = _dmy;
	_org_to_dm_clamped = point_distance(_cosx,_cosy,clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2));

_phas_snap = _has_snap;
_has_snap = false;

	if _readytolaunch = false{ 
if _org_to_dm_clamped < (_wh*.15) or _snapping = true{
	
	_c_ = 50
	
if _org_to_dm_clamped < (_wh*.15) and _snapping = false
or _snapping = true
{
	if _has_snap = false 
if not is_system and clamp(_dmy,_bnd_y1,_bnd_y2) < _dh*.15 and clamp(_dmx,_bnd_x1,_bnd_x2) > _dw*.2 and clamp(_dmx,_bnd_x1,_bnd_x2) < _dw*.8
or is_system and clamp(_dmy,_bnd_y1,_bnd_y2) < _dh*(.075) and clamp(_dmx,_bnd_x1,_bnd_x2) > _dw*(.4) and clamp(_dmx,_bnd_x1,_bnd_x2) < _dw*(.6){
fx = (_dw/2)-(_ww/2); fy = max(0,_bnd_y1); _org_to_fx = point_distance(_orgx,_orgy,fx,fy);  
//if _snapping = false if _has_snap = false if _org_to_fx > _c_ if _org_to_dm_clamped > _c_ 
if _phas_snap = false play_sound_ext(snd_click,.8,1.2,1,0); _snapping = true; _has_snap = true;}//snap to top

}
//corners
_snap_range = .05;
if _has_snap = false{

/*
if point_distance(clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2),min(_dw-5,_bnd_x2),min(_dh-5,_bnd_y2)) < max(_dw,_dh)*(_snap_range*.75) {
	if is_system = true {fx = floor(_dw/2); fy = 0;}
	//if is_system = true {fx = floor(_dw-_ww); fy = floor(_dh-_wh);}
	if is_system = false {fx = _dw-_ww; fy = _dh-_wh;}
	_org_to_fx = point_distance(_orgx,_orgy,fx,fy); 
	//if _snapping = false if _org_to_fx > _c_ if _org_to_dm_clamped > _c_ 
	if _phas_snap  = false play_sound_ext(snd_click,.8,1.2,1,1); _snapping = true; _has_snap = true;}//BR
	
if point_distance(clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2),max(5,_bnd_x1),min(_dh-5,_bnd_y2)) < max(_dw,_dh)*(_snap_range*.75) {
	if is_system = true {fx = floor(_dw/2)-(_ww); fy = 0;}
	//if is_system = true {fx = 0; fy = floor(_dh-_wh);}
	if is_system = false {fx = 0; fy = _dh-_wh;}
	_org_to_fx = point_distance(_orgx,_orgy,fx,fy); 
	//if _snapping = false  if _org_to_fx > _c_ if _org_to_dm_clamped > _c_ 
	if _phas_snap  = false play_sound_ext(snd_click,.8,1.2,1,1); _snapping = true; _has_snap = true;}//BL
*/
	
if point_distance(clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2),max(5,_bnd_x1),max(5,_bnd_y1)) < max(_dw,_dh)*_snap_range {
	fx = 0; fy = 0; _lerp *= 2; _org_to_fx = point_distance(_orgx,_orgy,fx,fy);
	//if _snapping = false  if _org_to_fx >= _c_ and _org_to_dm_clamped > _c_ 
	if _phas_snap  = false play_sound_ext(snd_click,.8,1.2,1,1); _snapping = true; _has_snap = true;} //snap to top left
	
if point_distance(clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2),min(_dw-5,_bnd_x2),max(5,_bnd_y1)) < max(_dw,_dh)*_snap_range {
	{fx = _dw-_ww; fy = 0;}
	_lerp *= 2; _org_to_fx = point_distance(_orgx,_orgy,fx,fy);
	//if _snapping = false  if _org_to_fx > _c_ if _org_to_dm_clamped > _c_ 
	if _phas_snap  = false play_sound_ext(snd_click,.8,1.2,1,1); _snapping = true; _has_snap = true;}//snap to top right
	
/*
if point_distance(clamp(_dmx,_bnd_x1,_bnd_x2),clamp(_dmy,_bnd_y1,_bnd_y2),(_dw/2),_dh*.95) < max(_dw,_dh)*.1 {
	fx = _lx; fy = _ly; _org_to_fx = point_distance(_orgx,_orgy,fx,fy); _readytolaunch = true; 
	if _snapping = false  play_sound_ext(snd_click,.8,1.2,1,1); _snapping = true; _has_snap = true; 

	}//middle bottom 
*/
}

}
}

if _has_snap = false _snapping = false;



if fy < 0 fy = 0;
	
/*
	if _readytolaunch = true {
	fx = _lx+lengthdir_x(_org_to_dm*.1,_dir); fy = _ly+lengthdir_y(_org_to_dm*.1,_dir);}*/
	
	_adj_ = 4; //if _readytolaunch = true {if _tminus < 30 _adj_ *= 15; if _tminus >= 30 _adj_ /= 2;}
	_wrx = trickle(_wrx,fx,_adj_/_lerp)
	_wry = trickle(_wry,fy,_adj_/_lerp)
	

	
	
	_bnc_os = 0;
	if _stun > 0 _bnc_os = 2;
		//NEW for bounce os
		if _readytolaunch = false {
		_wrx = clamp(_wrx,_bnd_x1+_bnc_os,(_bnd_x2-_ww)-_bnc_os)
		_wry = clamp(_wry,_bnd_y1+_bnc_os,(_bnd_y2-_wh)-_bnc_os)
		}
	

	
	// SET POSITION (throttled to display refresh)
	// A window can never VISUALLY move faster than the monitor refreshes.
	// At 120fps game speed, setting position every frame pays two DWM
	// composition stalls per visible movement = fps cut in half. Gate the
	// OS call to refresh rate; the sim keeps running at full speed.
	_wmove_gate += display_get_frequency() / game_get_speed(gamespeed_fps);
	if _wmove_gate >= 1 {
		_wmove_gate = min(_wmove_gate-1, 1);
		var _rx = round(_wrx);
		var _ry = round(_wry);
		// int-vs-int compare: the old float compare was ALWAYS true
		if is_system if _rx != argument0 or _ry != argument1 window_set_position(_rx,_ry);
	}
	//if not is_system x = _wrx; y = _wry;
	// center from our own state: no getter right after a setter (sync flush)
	_center_x = _wrx+(_ww/2);
	_center_y = _wry+(_wh/2);

}

	


if is_system and mouse_check_button_released(mb_right)
or not is_system and mouse_check_button_released(mb_left)
if _selected = true{_selected = false;
if _org_to_dm > 2


	if _snapping = false or _readytolaunch = true
	if _stun <= 0{_selected = false;

_dir = point_direction(_orgx,_orgy,_dmx,_dmy); 
		_len = _org_to_dm; 

		if _do_slide _spd = _len/lerp(_band,_band/2,_org_to_dm/max(_dw,_dh)*.3);
		
		_bounceresist += 3;

		

		 

_readytolaunch = false;}
}




	_bnc_os = -3;
// IF MOVING SLOW DOWN
if _spd > 0{
	if highest_speed < _spd highest_speed = _spd;
	//										BOUNCE
	_bnc_fast = .98; _bnc_slow = .975;


	_cc = (max(_dw,_dh)/6); _cc = _spd/_mxspd; _bnc = lerp(_bnc_slow,_bnc_fast,clamp(_cc,0,1)); 	





	// SET POSITION (throttled to display refresh)
	// A window can never VISUALLY move faster than the monitor refreshes.
	// At 120fps game speed, setting position every frame pays two DWM
	// composition stalls per visible movement = fps cut in half. Gate the
	// OS call to refresh rate; the sim keeps running at full speed.
	_wmove_gate += display_get_frequency() / game_get_speed(gamespeed_fps);
	if _wmove_gate >= 1 {
		_wmove_gate = min(_wmove_gate-1, 1);
		var _rx = round(_wrx);
		var _ry = round(_wry);
		// int-vs-int compare: the old float compare was ALWAYS true
		if is_system if _rx != argument0 or _ry != argument1 window_set_position(_rx,_ry);
	}
	if not is_system x = _wrx; y = _wry;
	// center from our own state: no getter right after a setter (sync flush)
	_center_x = _wrx+(_ww/2);
	_center_y = _wry+(_wh/2);
	
	if _snapping = false
	if _has_snap = false
	if _readytolaunch = false
	
		if _do_bounces {_os = (_dw/6); _hitwall = false;
	if _wry <= _bnd_y1 
	or _wry >=  _bnd_y2-_wh{
		cur_bounces++;
	
		
		
		_spd = _spd*_bnc
		
		_dir = 360-_dir;
		
		_hitwall = true;
		_stun = _stun_;
		if cur_bounces = 1 _stun += lerp(0,3,_spd/_mxspd);
		if is_system if _endonbounce = true game_end();
		play_sound_ext(_snd_,lerp(.2,.75,abs(_wvspd/_os)),lerp(.75,2,abs(_wvspd/_os)),lerp(0,1,abs(_wvspd/_os)),0);
		}
		
	if _wrx <= _bnd_x1 
	or _wrx >= _bnd_x2-_ww{
		
		cur_bounces++;
		
		_spd = _spd*_bnc
		_dir = 180-_dir;
		_hitwall = true;
		_stun = _stun_; 
		if cur_bounces = 1 _stun += lerp(0,3,_spd/_mxspd);
		
		play_sound_ext(_snd_,lerp(.2,.75,abs(_wvspd/_os)),lerp(.75,2,abs(_whspd/_os)),lerp(0,1,abs(_whspd/_os)),0);}
	
		if _hitwall = true{
		_bnc_os = 1;
		
		
		_bounceresist -= 1;

	
		//NEW for bounce os
		
		_wrx = clamp(_wrx,_bnd_x1+_bnc_os,(_bnd_x2-_ww)-_bnc_os)
		_wry = clamp(_wry,_bnd_y1+_bnc_os,(_bnd_y2-_wh)-_bnc_os)
	
		
		}
	
	
	}
	

}

//if _stun <= 0{


_wfric_ = lerp(.26,3,delta/max(delta,2));
if fps <= 60 _wfric_ = lerp(1,2.5,delta/max(delta,2));
if fps <= 50 _wfric_ = lerp(1,2.5,delta/max(delta,2));
if fps <= 40 _wfric_ = lerp(0,2,delta/max(delta,2));
if fps <= 30 _wfric_ = lerp(0,2.5,delta/max(delta,2));

_wfric_ = 1-((1-_wfric)*_wfric_);
_wfric_ = lerp(_wfric_,1,clamp(__stun,0,1));
if _bounceresist > 0 _wfric_ = lerp(_wfric_,1,clamp(_bounceresist/_bounceresist_,0,1));
if _spd <= _mxspd _spd *= _wfric_;
if _spd > _mxspd _spd = _spd-(_mxspd-(_mxspd*_wfric_));


if in_range(_spd,0,.05) 
or _readytolaunch = true _spd = 0;

if _dir > 360 or _dir < 0{_dir = _dir-(360*floor(_dir/360))}


if _spd > 0  {


_wvspd = lengthdir_y(_spd*delta,_dir);
_whspd = lengthdir_x(_spd*delta,_dir);

_whspd = clamp(_whspd,-_mxspd,_mxspd)
_wvspd = clamp(_wvspd,-_mxspd,_mxspd);


	if _snapping = false{
	_tspd_ = _whspd;  if _stun > 0 _tspd_ = lerp(_tspd_*.05,0,clamp(__stun,0,1));
	_wrx = clamp(_wrx+_tspd_,_bnd_x1+_bnc_os,(_bnd_x2)-_bnc_os)

	
	
	
	_tspd_ = _wvspd;   if _stun > 0 _tspd_ = lerp(_tspd_*.05,0,clamp(__stun,0,1));
	_wry = clamp(_wry+_tspd_,_bnd_y1+_bnc_os,(_bnd_y2-_wh)-_bnc_os)
	


	}
}



_cx = _wrx+(_ww/2);
_cy = _wry+(_wh/2);


_ra_xval = _dmx/_dw
_ra_yval = _dmy/_dh;
_deb_line1 = point_distance(_dw/2,_cy,_dmx,_cy);
_deb_line1 = -((_dw/2)-_dmx)

_ra_val = 	
lerp(0,lerp(0,1,sin(degtorad(_dir))),
lerp(1,0,abs(cos(degtorad(_dir))) ));

_ra_len = lerp(
_dw/2,_dh,
_ra_val
)*.8

_ra_os = 0;

_arrow_val = 
clamp(lerp(0,1,
clamp(point_distance(_cx,_cy,_dmx,_dmy),0,_ra_len)/(_ra_len*lerp(2,.8,_ra_val)))
,0,1);

_arrow_index_max = 2;


_arrow_index = 0;

if _arrow_index_max = 2{
if _arrow_val > .4 _arrow_index = 1;
if _arrow_val > .7 _arrow_index = 2;}

if _arrow_index_max = 3{
if _arrow_val > .4 _arrow_index = 1;
if _arrow_val > .7 _arrow_index = 2;
if _arrow_val > .9 _arrow_index = 3;}

if _arrow_index_max = 4{
if _arrow_val > .3 _arrow_index = 1;
if _arrow_val > .5 _arrow_index = 2;
if _arrow_val > .7 _arrow_index = 3;
if _arrow_val > .9 _arrow_index = 4;}

if _arrow_index_max = 5{
if _arrow_val > .27 _arrow_index = 1;
if _arrow_val > .47 _arrow_index = 2;
if _arrow_val > .6 _arrow_index = 3;
if _arrow_val > .75 _arrow_index = 4;
if _arrow_val > .9 _arrow_index = 5;}


}