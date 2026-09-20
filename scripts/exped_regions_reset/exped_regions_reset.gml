/// @description exped_regions_reset() - THE REGION BREAK (q287): everything keyed by a region index or a node of one is dropped - the trips (the crews come home, unhurt), the quest boards, the memories, the lanes, the seats, the scars, the factions, the population, the news, the villain threads, the region cache. The hauls and the board stay (his gold-key precedent: no migration)
function exped_regions_reset() {
	exped_init();
	var _e = g.exped;
	for (var _i = 0; _i < array_length(g.sprites); _i++) g.sprites[_i].trip = false;
	_e.trips = [];
	_e.offers = {}; _e.mem = {}; _e.lanes = {}; _e.seat = {}; _e.scars = {}; _e.scar_order = []; _e.fac = {}; _e.pop = {}; _e.news = []; _e.vil = {};
	g.regions = {};
	g.exped_owed = 0;
}
