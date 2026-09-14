/// @description get_ability_cost() - the units price of the NEXT
/// discovery. Myriad's curve kept: linear-ish digit growth with a
/// widening multiplier plus a gentle quadratic tail, and hand-tuned
/// first steps (1 / 10 / 50 / 250) so the early game snowballs.
function get_ability_cost() {
	var _nau = g.new_abilities_unlocked + 1;
	var _c = (_nau - 2) * lerp(1.15, 2.25, clamp(_nau / 60, 0, 1));
	_c += (.005 * g.new_abilities_unlocked) * g.new_abilities_unlocked;
	g.new_ability_cost = dig_to_arb(max(_c, 0));

	if (g.new_abilities_unlocked == 0) g.new_ability_cost = arb(1);
	if (g.new_abilities_unlocked == 1) g.new_ability_cost = arb(10);
	if (g.new_abilities_unlocked == 2) g.new_ability_cost = arb(50);
	if (g.new_abilities_unlocked == 3) g.new_ability_cost = arb(250);

	// (Bargain Hunter was cut from the roster, 2026-09-14)
}
