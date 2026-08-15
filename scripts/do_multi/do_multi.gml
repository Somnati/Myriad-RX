/// @description  do_multi(a_val,b_val);
/// @param a_val
/// @param b_val
function do_multi(argument0, argument1) {

	//var _val, _acoe, _bcoe, _aexp, _bexp, _diffexp, _cexp, _ccoe, _ecut;
	
	if argument0 = 0 or argument1 = 0 return 0;

	_val = argument0;


	//grab vars
	_aexp = 0; _bexp = 0; _acoe = 0; _bcoe = 0;

	_acoe = frac(argument0);
	_bcoe = frac(argument1);

	_aexp = floor(argument0);
	_bexp = floor(argument1);
	
	//find ediff
	_diffexp = _bexp-_aexp;

	//match coe
	_acoe *= 10;
	_bcoe *= 10;

	//add Aa+Ba
	_ccoe = _acoe*_bcoe;

	//set final Ee
	_cexp = _aexp+_bexp;


	// convert overflow to e
	if _ccoe != 0 while _ccoe < 1 { _cexp -= 1; _ccoe *= 10;} 
	while _ccoe >= 10 { _cexp += 1; _ccoe /= 10;} 


	//correct final coe
	_ccoe  /= 10;
	_val = _cexp+_ccoe;

	
	return _val;





}
