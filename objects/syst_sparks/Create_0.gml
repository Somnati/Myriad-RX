/// syst_sparks - THE SPARK POOL. Myriad DE's obj_eff_shardspark, which
/// bursts a few tiny pixels out of a dial every time it pays.
///
/// DE SPAWNS ONE INSTANCE PER PIXEL. Up to two hundred of them exist at
/// once, each with its own Create, Step and Draw dispatch, each created
/// and destroyed several times a second forever. The behaviour is
/// lovely and the delivery is the most expensive way GameMaker offers
/// to move a single pixel.
///
/// SO THIS IS ONE OBJECT AND A POOL OF STRUCTS. Every spark is
/// preallocated in this event and never freed: a burst writes into a
/// free slot, a death SWAPS the dead spark with the last live one and
/// decrements the count. Nothing is allocated, nothing is collected,
/// the live sparks are always a contiguous run at the front of the
/// array, and the whole system is one Step loop and one Draw loop.
/// At the cap that is 1 event dispatch instead of 200.
///
/// The physics is DE's, term for term - see the Step. The two changes
/// are deliberate: every term is delta-scaled (DE leaves the wind
/// un-scaled, which makes sparks drift further on a 144hz machine than
/// on a 60hz one), and a spark fades over its last few frames instead
/// of vanishing mid-air.

depth = -15;   // rm_clicker's plan: header -1000, menu -520, drawer -20.
               // BEHIND the drawer, as DE puts them behind the dial
               // (o.depth = depth+5) - they spray out from under it.

n  = 0;        // live sparks: always p[0 .. n-1]
wr = 0;        // the round-robin cursor used only when the pool is full

// preallocated, once. The fields are DE's:
//   vx/vy  the slow persistent drift
//   bx/by  the burst impulse, decaying to nothing
//   wd/wdc/wt/ws  the wandering wind that makes them swirl
//   sc/smin       scale, easing from big to small
//   hp/hp0        life left, and what it started at (for the fade)
p = array_create(SPARK_MAX);
for (var _i = 0; _i < SPARK_MAX; _i++)
	p[_i] = { x : 0, y : 0, vx : 0, vy : 0, bx : 0, by : 0,
	          wd : 0, wdc : 0, wt : 1, ws : 0,
	          sc : 1, smin : 1, hp : 0, hp0 : 1, col : c_white };
