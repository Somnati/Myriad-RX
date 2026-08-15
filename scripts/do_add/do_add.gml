/// @description  do_add(a_val,b_val);
/// @param a_val
/// @param b_val
function do_add(argument0, argument1) {



	//var _acoe, _bcoe, _aexp, _bexp, _ccoe, _cexp, _diffexp, _val, _hardpoint;
	_val =  0;
	_acoe = frac(argument0);
	_bcoe = frac(argument1);

	_aexp = floor(argument0);
	_bexp = floor(argument1);

	_hardpoint = 100;


	//find ediff
	_diffexp = _bexp-_aexp;

	if _diffexp >= -_hardpoint
	    if _diffexp <= _hardpoint{
    
	//match coe
	_acoe *= 10;
	_bcoe *= 10;

	//reconfigure Bcoe to match Aexp
	_bcoe *= power(10,_diffexp);

	//add Aa+Ba
	_ccoe = _acoe+_bcoe;

	//set final exp
	_cexp = _aexp;

	// convert overflow to e
	if _ccoe != 0 while _ccoe < 1 { _cexp -= 1; _ccoe *= 10;}
	while _ccoe >= 10 { _cexp += 1; _ccoe /= 10;} 
	
	//correct final coe
	_ccoe  /= 10;

	_val = _cexp+_ccoe;

	}//end hardpoint

	    //if failed
	if _diffexp <= -_hardpoint
	    or _diffexp >= _hardpoint{
    
	if argument0 >
	    argument1{
	_val = argument0;}

	if argument0 <
	    argument1{
	_val = argument1;}
	}

	return _val;




}
