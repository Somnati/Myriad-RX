// population bookkeeping down (bezier_bits caps spawns off g.bez_n)
g.bez_n -= 1;
// died without arriving (room change, cull): release its share anyway,
// or the counter would hold that profit back forever
if (amt > 0) {
	g.profit_flight = (g.profit_flight > amt)
		? do_subtract(g.profit_flight, amt) : 0;
	amt = 0;
}
