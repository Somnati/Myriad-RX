/// @description  do_div(a_val,b_val);
/// @param a_val
/// @param b_val
function do_div(argument0, argument1) {
	
	if argument1 = 0 return argument0;

	//grab vars
	_acoe = frac(argument0);
	if argument0 > 0 if _acoe < .1 _acoe = .1;
	_bcoe = frac(argument1);
	if argument1 > 0 if _bcoe < .1 _bcoe = .1;

	_aexp = floor(argument0); 
	_bexp = floor(argument1);

	//add Aa+Ba
	_acoe *= 10; 
	_bcoe *= 10; 
	_ccoe = _acoe/_bcoe;

	//set final Ee
	_cexp = _aexp-_bexp;

	if _ccoe != 0 while _ccoe < 1 { _cexp -= 1; _ccoe *= 10;} else return 0;
	if _cexp = 0 _ccoe = round(_ccoe);

	//correct final coe
	_ccoe  /= 10;
	_val = _cexp+_ccoe;
	if _val < 0 _val = 0;
	
	
	return _val;
}
