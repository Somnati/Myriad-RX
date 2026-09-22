/// @description cas_buy(c, i, payer, [qty]) -> units bought: tier i of cascade c, PAID FROM THE OTHER SIDE'S STOCK (payer - the collider's law: each side is the other's fuel); a bought unit raises count and bought (the per-10 milestone rides bought alone); tier i unlocks once tier i-1 of the SAME side has been bought; qty "max" runs until the payer runs dry (geometric costs bound the loop, the repeat count is the runaway guard)
function cas_buy(_c, _i, _payer, _q = 1, _stepk = 1) {
	if (_i > 0 && _c.bought[_i - 1] <= 0) return 0;
	if (_q == "max") _q = 100000;
	var _did = 0;
	repeat (_q) {
		var _cost = cas_cost(_c, _i, _stepk);
		if (_payer.stock < _cost) break;
		_payer.stock = lg_sub(_payer.stock, _cost);
		_c.bought[_i]++;
		_c.count[_i] = lg_add(_c.count[_i], 0);
		_did++;
	}
	return _did;
}
