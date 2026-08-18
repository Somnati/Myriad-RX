/// scr_bignum_vis_mantissa
/// Adapter for the host game's bignum format:
///   value = mantissa * 10^exp, stored as exp + mantissa/10
/// Example: 12.543 -> value 5.43e12 -> returns "5430000".
///
/// Coefficient decode is (_b - floor(_b)), NOT frac(_b): GML's frac keeps
/// the sign, so for sub-1 values (stored negative, e.g. 0.5 -> -0.5) it
/// returns -0.5 where the true coefficient is 0.5. Subtracting floor
/// yields [0,1) for every input.
///
/// Rounded to 7 significant digits before extraction, matching the 7
/// digits pulled. Host arithmetic renormalizes the mantissa into [1,10)
/// (verified in do_add / do_subtract / do_multi), so the only dirt that
/// reaches this function is float dust, and rounding removes it. Same
/// philosophy as the frequency object's string_format(frac(v),0,12).
/// Even at e308 the exponent spends only 3 of the double's ~15 sig figs,
/// so 7 mantissa digits are always safe.

function bignum_vis_mantissa_string(_b) {
    var _mag  = floor(_b);
    var _mant = (_b - _mag) * 10;   // [1, 10) for normalized values

    // Adaptive digit budget: a double carries ~15 significant figures,
    // the exponent's integer digits spend some, and one guard digit is
    // reserved. At everyday magnitudes this yields 12 true mantissa
    // digits (matching the old string_format(...,0,12) depth); at
    // extreme magnitudes it shrinks honestly instead of inventing dust.
    var _exp_digits = (abs(_mag) >= 1) ? (floor(log10(abs(_mag))) + 1) : 1;
    var _n = clamp(15 - _exp_digits - 2, 7, 12);

    // Round ONCE into an integer and never return to float-land. Integers
    // this size are exact in doubles, so the digits come off the decimal
    // string with zero drift. Rounding then dividing back (a previous
    // approach) re-poisons the value with binary representation error
    // (1.2 as a double is 1.1999...96), which a floor-based digit pull
    // amplifies into a wrong count and a tail of phantom nines.
    var _scale = power(10, _n - 1);
    var _int   = round(_mant * _scale);
    if (_int >= _scale * 10) _int = _scale * 10 - 1;   // dust at 9.99...x
                                                       // would carry into
                                                       // the next exponent:
                                                       // clamp instead

    var _digits = string(_int);
    while (string_length(_digits) < _n) _digits = "0" + _digits;
    return _digits;
}
