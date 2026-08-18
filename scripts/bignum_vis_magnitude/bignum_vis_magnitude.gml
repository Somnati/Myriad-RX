/// scr_bignum_vis_magnitude
/// Adapter for the host game's bignum format:
///   value = mantissa * 10^exp, stored as exp + mantissa/10
///   1.00e308 -> 308.1, and 5.43e12 -> 12.543
///
/// Sub-1 values pack NEGATIVE: 0.5 = 5e-1 -> stored -0.5. floor() alone
/// decodes the exponent correctly for every case, including those
/// (floor(-0.5) = -1). Do NOT abs() the input: abs(-0.5) = 0.5 decodes as
/// the value 5, ten times too big.
///
/// Zero is stored as literal 0 (do_subtract clamps negatives to it),
/// which decodes to magnitude 0 with an all-zero mantissa: draws nothing.

function bignum_vis_magnitude(_b) {
    return floor(_b);
}
