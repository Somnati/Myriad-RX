/// A BURST THAT NEVER FULLY SPAWNED still owes the counter. The
/// population cap can swallow a spawn (bezier_bits caps at 48), and
/// the drained-per-spawn `amt` is exactly what was never handed to a
/// mote. Release it here or the counter would hold that profit back
/// until the last mote in the game happened to die.
if (amt > 0) {
	g.profit_flight = (g.profit_flight > amt)
		? do_subtract(g.profit_flight, amt) : 0;
	amt = 0;
}
