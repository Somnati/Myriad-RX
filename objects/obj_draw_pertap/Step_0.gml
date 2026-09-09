depth = 0;   // over the visualiser (obj_bignum5 sits at 50), under the
             // header (-1000) and everything the menu owns

// ⚖️ IT FADES IN WHEN THE NUMBER STARTS TO MATTER, and never fades back
// out - DE's rule, kept. 110 is the threshold DE used on gold; RX's
// money is g.profit, so it reads that. Before then the readout would
// only say "1" next to a profit counter also saying single digits.
//
// (DE also lifted this to depth 100 while its upgrade drawer was open.
// RX has no such drawer here - the line is dropped rather than faked.)
if (g.profit > arb(110)) alpha = trickle(alpha, 1, 25);
