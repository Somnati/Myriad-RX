function do_floor(argument0) {

	var _acoe, _aexp, _hardpoint;

	_aexp = floor(argument0);

	_hardpoint = 10;
	if _aexp <= _hardpoint{
	_acoe = frac(argument0);
	_acoe = _acoe*power(10,_aexp+1);
	_acoe = floor(_acoe);
	_acoe = _acoe/power(10,_aexp+1);

	return _acoe+_aexp;}

	if _aexp > _hardpoint return argument0;











}
