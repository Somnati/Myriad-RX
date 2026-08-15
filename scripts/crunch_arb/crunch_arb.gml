/// @description  crunch_arb(val);
/// @param val
function crunch_arb() {


	_aexp = floor(argument[0]);//exponent

	// dust-proof mantissa: snap once to 6 decimals, then never trust the
	// raw float again. frac() of a packed value carries binary dust
	// (2 + 4/10 is stored as 2.3999999999999998, which the old floor()
	// path truncated into "399"). The carry guard handles dust sitting
	// just under the next exponent (9.9999999x).
	_acoe = round((argument[0] - _aexp) * 10 * 1000000) / 1000000; //significant digit
	if _acoe >= 10 {_acoe /= 10; _aexp += 1;}

	_e = floor(_aexp/3);
	//abrieviation
	_abr = "$" + string(_aexp);
	_abr_id = _e-1;
	if _e <= 4 get_abri_scientific();

	tot = 1; dec = 2;
	_val_ = _acoe;

		// non scientific numb calc
	    if _e < _abr_id{
	        //calculate 3's: integer mod, exact at any exponent (the old
	        //float dance ((_aexp/3)-floor(_aexp/3))*100 loses precision
	        //once exponents get huge)
	        var _te = _aexp mod 3;
	        if _te = 1 {tot = 2; dec = 1; _val_ *= 10;}
	        if _te = 2 {tot = 3; dec = 0; _val_ *= 100;}

	        //determine tot/dec
	        if _aexp = 0 {tot = 1; dec = 0;}
	        if _aexp = 1 {tot = 2; dec = 0;}
	        if _aexp = 2 {tot = 3; dec = 0;}
	    }

			// insignificant decimal removal
			if _aexp >= 500 if dec > 1 dec = 1
			if _aexp >= 1000 if dec > 0 dec = 0

		// round, never floor: any residual dust sits a hair BELOW the
		// true value, so floor eats a whole unit (400 -> 399) while
		// round recovers it. The dec > 0 paths were always safe because
		// string_format rounds them.
		if dec = 0 _val_ = round(_val_);
		_val_ = string_format(_val_,tot,dec);
	    _val_ = string_insert(_val_,_abr,0);

		return   _val_;
}
