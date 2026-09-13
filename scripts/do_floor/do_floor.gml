function do_floor(argument0) {

	var _acoe, _aexp, _hardpoint;

	_aexp = floor(argument0);

	_hardpoint = 10;
	if _aexp <= _hardpoint{
	_acoe = frac(argument0);
	_acoe = _acoe*power(10,_aexp+1);
	// the same epsilon as do_ceil, mirrored: arb(300) packs as 2.3, whose
	// frac x1000 is 299.99999999999983 - a plain floor read 299 (and 448
	// read 447). See do_ceil for why 1e-4 cannot touch a real value
	_acoe = floor(_acoe + .0001);
	_acoe = _acoe/power(10,_aexp+1);

	return _acoe+_aexp;}

	if _aexp > _hardpoint return argument0;











}
