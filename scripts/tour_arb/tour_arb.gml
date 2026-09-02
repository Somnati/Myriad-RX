/// tour_arb - THE BIG-NUMBER LIBRARY  (engine/arb)
/// A TOUR SCRIPT: comments only, nothing runs.
/// This is YOUR library from DE (do_add, do_multi and friends are
/// DE's names). Three scripts were added; one rule was learned the
/// hard way.

// ========================== THE FORMAT ==============================
// A packed arb is ONE real:  exponent + mantissa/10
//   arb(1)      = 0.1      (10^0, mantissa 1)
//   arb(100)    = 2.1      (10^2, mantissa 1)
//   arb(2500)   = 3.25     (10^3, mantissa 2.5)
// floor() is the order of magnitude, the fraction x10 is the leading
// digits. Because bigger numbers pack to bigger reals, a plain
//     if (g.profit >= cost)
// is a VALID comparison. That is the whole reason for the format.

// ========================== THE FILES ===============================
//   arb(n)                 pack a plain number.
//   unarb(a)               unpack to a plain real: frac x 10^(exp+1).
//                          Only meaningful while the number fits a
//                          real - use it for small counts.
//   do_add / do_subtract / do_multi / do_div / do_power
//                          the arithmetic. do_power's low tier loops
//                          once per order of magnitude - keep it out
//                          of hot paths.
//   do_ceil / do_floor     round to whole units (saves floor on load).
//   crunch_arb(a)          the DISPLAY string: "2.50k", "1.2m" - the
//                          suffix ladder is get_abri_scientific.
//   arb_log10(a)           exact log10 of a packed value.
//   log_to_arb(lg)         pack 10^lg EXACTLY. Added for RX: DE's
//                          dig_to_arb is a lerp approximation that
//                          undershoots mid-range coefficients.
//   dig_to_arb             DE's version, kept for reference.
//   do_scale(a, f)         multiply by a PLAIN REAL of any size,
//                          fractions included, in log space. THE safe
//                          way to take a percentage or a multiplier.

// =========================== THE RULE ===============================
// THE LIBRARY DOES NOT DO VALUES BELOW 1.
//   arb(0.15) packs malformed. do_subtract / do_div's normalise loops
//   spin FOREVER on the negative coefficients that fall out of it -
//   a boot freeze at "About to startroom", found the hard way.
// So:
//   - a percentage is do_scale(a, 0.01), never do_multi(a, arb(.01))
//     (DE wrote the latter in update_clicker; RX does not)
//   - any SERIES maths (geometric costs, level curves) stays in
//     log10 the whole way and packs ONCE at the end via log_to_arb
//   - a subtraction that could go negative is guarded first:
//         (a > b) ? do_subtract(a, b) : 0
//   - do_scale clamps results under 1 to arb(1); currencies here are
//     whole units, which is exactly why that is safe

// ========================= WHERE IT IS USED =========================
// Every currency and cost: g.profit, dial gpc/gps, prices, the
// counter's hold-back ledger. dial_gps / dial_cost / dial_lvdiv show
// the log-space style: compute in plain reals, pack at the end.
