/// @description upgrade_inflation();
/// DE's price drift: every upgrade ever bought makes the next one
/// dearer, three percent per hundred, ceiling 3x.
///
///     1 + clamp(0.03 * (total / 100), 0, 2)
///
/// RESALE NEVER SEES IT. DE captures its sell price BEFORE applying
/// this line (set_ucost: `_sell = _cost`, and only then `_cost *= ...`),
/// and that asymmetry is load-bearing rather than incidental. Quotes
/// drift up, refunds are quoted off the original base, so holding a
/// slot slowly becomes better than churning it. It is also what makes
/// a refund PROVABLY smaller than what was paid: the refund is a
/// fraction of the un-inflated price, and the price paid was that same
/// base at an inflation factor that only ever grew. Without the rule a
/// long-held slot could refund more than it cost.
function upgrade_inflation() {
	upgrade_init();
	return 1 + clamp(0.03 * (g.upg.total / 100), 0, 2);
}
