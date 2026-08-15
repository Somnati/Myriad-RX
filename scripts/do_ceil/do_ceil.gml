function do_ceil(argument0) {

	_acoe = frac(argument0);
	_aexp = floor(argument0);

	_hardpoint = 10;
	if _aexp <= _hardpoint{
	_acoe = _acoe*power(10,_aexp+1);
	_acoe = ceil(_acoe);
	_acoe = _acoe/power(10,_aexp+1);

	//overflow_correction
	if _acoe >= 1{
	_acoe /= 10;
	_aexp += 1;}

	}

	return _acoe+_aexp;







}
