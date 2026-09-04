/// scr_digit_window
/// DigitWindow: pure data layer. Extracts digits from a bignum at a given
/// magnitude offset. Owns digit extraction only. Knows nothing about zoom,
/// LOD state, or drawing.
///
/// Digit indexing convention used throughout the module:
///   magnitude k = the digit worth 10^k (units digit is k = 0)
///   get_digits(offset, count) returns digits covering magnitudes
///   [offset + count - 1 .. offset], most significant first.
///
/// FAKE DEPTH: digits below float precision can be synthesized so deep
/// zoom always has content (the old frequency system's seeded-shuffle
/// trick). Fakes are a PURE FUNCTION of (real digits, magnitude): stable
/// while the real digits are stable, reshuffled whenever profit's real
/// digits change, mimicking how true sub-digits churn. No RNG state is
/// touched, so nothing can flicker frame to frame on a static value.

function DigitWindow() constructor {
    digit_str   = "0";   // real mantissa digits, most significant first
    mag         = 0;     // order of magnitude of the most significant digit
    fake_digits = true;  // toggle: synthesize below-precision digits
    fake_floor  = 0;     // lowest magnitude fakes may occupy. Fakes fill
                         // the gap between float precision and the value's
                         // REAL bottom, never below it: with integer gold
                         // the units digit (mag 0) is atomic, so nothing
                         // imaginary exists beneath it. Lower this only if
                         // the game ever tracks fractional profit
    seed        = 0;     // hash of the real digits + magnitude
    has_real    = false; // zero values get no fake depth

    /// @func set_value(bignum)
    /// @desc Refresh the window from the host game's bignum.
    static set_value = function(_bignum) {
        digit_str = bignum_vis_mantissa_string(_bignum);
        mag       = bignum_vis_magnitude(_bignum);
        if (digit_str == "") digit_str = "0";

        // THE UNIT IS THE ATOM (his report, 2026-09-04: sub-tier white
        // squares under the units at deep zoom). The mantissa string
        // carries up to 12 significant digits, so for a value like
        // 1234.33 the digits below the units place are REAL digits to
        // get_digits and the unit field draws them as a partial - a
        // fraction of a unit, rendered as smaller squares. Nothing below
        // fake_floor exists in this game, so cut it off here, at the
        // data layer, and no renderer path can ever see it.
        var _keep = mag - fake_floor + 1;
        if (_keep < 1) digit_str = "0";
        else if (string_length(digit_str) > _keep)
            digit_str = string_copy(digit_str, 1, _keep);

        // seed from every real digit plus the magnitude: any change in
        // profit's visible digits reshuffles the fake strata below
        var _len = string_length(digit_str);
        var _h   = mag mod 1000003;
        if (_h < 0) _h += 1000003;
        has_real = false;
        for (var i = 1; i <= _len; i++) {
            var _c = real(string_char_at(digit_str, i));
            if (_c > 0) has_real = true;
            _h = (_h * 31 + _c) mod 1000003;
        }
        seed = _h;
    };

    /// @func magnitude()
    static magnitude = function() {
        return mag;
    };

    /// @func fake_digit(m)
    /// @desc Deterministic pseudo-digit for magnitude m. Squared-hash
    ///       keeps everything under 1e12, exact in doubles.
    static fake_digit = function(_m) {
        var _k = _m mod 1000003;
        if (_k < 0) _k += 1000003;
        var _h = (seed + _k * 131) mod 1000003;
        _h = (_h * _h + _k) mod 1000003;
        return _h mod 10;
    };

    /// @func get_digits(offset, count)
    /// @desc Array of digits (0-9), most significant first, covering
    ///       magnitudes [offset + count - 1 .. offset]. Positions above
    ///       the value's magnitude return 0. Positions below stored
    ///       precision return synthesized digits when fake_digits is on
    ///       (and the value is nonzero), else 0.
    static get_digits = function(_offset, _count) {
        var _out = array_create(_count, 0);
        var _len = string_length(digit_str);
        for (var i = 0; i < _count; i++) {
            var _m   = _offset + _count - 1 - i;  // magnitude this slot represents
            var _idx = mag - _m + 1;              // 1-based index into digit_str
            if (_idx >= 1 && _idx <= _len) {
                _out[i] = real(string_char_at(digit_str, _idx));
            } else if (_idx > _len && fake_digits && has_real && _m >= fake_floor) {
                _out[i] = fake_digit(_m);
            }
        }
        return _out;
    };
}
