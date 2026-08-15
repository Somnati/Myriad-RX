/// @description  do_power(arb,real);
/// @param arb
/// @param real
function do_power(argument0, argument1) {
	var _bcoe, _exp, _real, e, _coe, d;

	_bcoe = frac(argument0)*10;
	_exp = floor(argument0);
	_real = argument1;

	e = floor(arb(_real));

	//TIER 0
	if e = 0{
	//base
	_coe = power(_bcoe,_real);

	_exp *= _real;
	return _exp+arb(_coe);
	}

	//TIER 1
	if e >= 1{d = power(10,e);
	_bcoe = arb(power(_bcoe,_real/d));
	_coe = _bcoe;
	repeat d-1 _coe = do_multi(_coe,_bcoe);

	_exp *= floor(_real);

	return _coe+_exp;
	}















}
