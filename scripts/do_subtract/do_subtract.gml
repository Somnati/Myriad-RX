/// @description  do_add(a_val,b_val);
/// @param a_val
/// @param b_val
function do_subtract(argument0, argument1) {


	if argument1 > argument0 return 0;

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
	_ccoe = _acoe-_bcoe;
	

	//set final exp
	_cexp = _aexp;
	//if _ccoe < 1 {_cexp -= 1; _ccoe *= 10;}
	if _ccoe != 0 while _ccoe < 1 { _cexp -= 1; _ccoe *= 10;} else return 0;
	//if _ccoe = 0 return 0;

	//correct final coe
	_ccoe  /= 10;

	_val = _cexp+_ccoe;

	}//end hardpoint


    


	return _val;




}
