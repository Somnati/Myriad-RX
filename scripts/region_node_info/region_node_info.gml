/// @description region_node_info(dest, region, ni) -> { rows : [{ k, v, col }], desc, lore } - a place's card, generated once and kept on the node
/// THE PLACE'S PAPERS (his ask, 2026-09-16: "population, economy, a
/// procedural description... a lore note... room count, current
/// faction"): everything a node says about itself, hashed off the
/// region's seed and the node's index (hash_mix - no roll of the
/// ambient stream, so nothing downstream shifts), the names it needs
/// rolled from sprite_name_gen under a seed of the node's own. Word
/// POOLS for the describing (his rule: pools for words are fine, fixed
/// lists of names are not - the people and the roads here are generated).
///   settled   population by size, the economy off the LAND the roads
///             reach (grain by the fields, timber by the woods, fish by
///             the coast...) and a tone; a two-clause description
///   dungeons  rooms, who holds it (a faction named off its foes), depth
///   camps     how many, who leads them, the chest
///   ruin / shrine / mine   age and what stands / whom it is to / the ore
///   the wild  the going, what is found, its foes
/// and a LORE line for every one. Cached as node.card (the region is
/// cached itself - region_get - so this is once a session a node).
/// THE FOLK: card.folk = { elder, other, keeper, trader } were four names of
/// the node's own (2026-09-16, morning) - SUPERSEDED the same day by
/// region_node_leader (the leader, on a term of months) and region_node_folk
/// (the keeper / trader / other, on terms of years), both hashed off the
/// wall clock with nothing saved; the rolls stay so the sign reads as it did.
function region_node_info(_d, _rg, _ni) {
	var _nd = _rg.nodes[_ni];
	if (is_struct(_nd[$ "card"])) return _nd.card;
	var _kk = region_kinds();
	var _seed = _rg.seed, _base = _ni * 131;
	// (a function literal sees no outer local: seed / base ride in)
	var _pick = function(_arr, _salt, _seed2, _base2) { return _arr[hash_mix(_seed2, _base2 + _salt) mod array_length(_arr)]; };
	var _rng  = function(_lo, _hi, _salt, _seed2, _base2) { return _lo + (hash_mix(_seed2, _base2 + _salt) mod max(1, _hi - _lo + 1)); };
	var _fmt  = function(_n) { var _s = string(_n), _o = "", _l = string_length(_s); for (var _i = 1; _i <= _l; _i++) { _o += string_char_at(_s, _i); if (_i < _l && ((_l - _i) mod 3) == 0) _o += ","; } return _o; };
	// two names of the node's own (the founder, the chief, the shepherd...)
	var _rs = random_get_seed();
	random_set_seed(hash_mix(_seed, _base + 77));
	var _n1 = str_cap(sprite_name_gen()), _n2 = str_cap(sprite_name_gen());
	// ...a keeper and a trader of its own (THE RECURRING FOLK, 2026-09-16: the shop, the escort's merchant, the lost one, the minded shop
	// all name these), and the shop's SIGN, rolled here under the node's seed so it reads the same on every visit (the pools were exped_shop's)
	var _n3 = str_cap(sprite_name_gen()), _n4 = str_cap(sprite_name_gen());
	var _sign, _sf = random(100);
	if (_sf < 40) _sign = "the " + choose("crooked", "bent", "dented", "rusty", "golden", "leaning", "quiet", "loud", "blue", "red", "old", "honest", "second", "little") + " " + choose("kettle", "nail", "spoon", "anvil", "boot", "hat", "goose", "pig", "lantern", "bucket", "bell", "crow", "wheel", "door");
	else if (_sf < 65) _sign = "the " + choose("three", "two", "seven", "nine", "twelve") + " " + choose("pigs", "spoons", "hats", "bells", "crows", "boots", "kettles", "geese");
	else if (_sf < 85) _sign = _n3 + "'s " + choose("ironmongery", "emporium", "stall", "shop", "goods", "odds and ends", "outfitters", "bits", "warehouse (small)");
	else _sign = choose("goods", "wares", "things", "sundries", "everything", "bits and pieces") + " " + choose("and more", "of quality", "for sale", "and such", "at prices");
	rng_release(_rs);
	var _civ = is_struct(_kk[$ _nd.kind]) && _kk[$ _nd.kind].civ;
	// the land the roads reach, and the settled neighbour (the lore leans on them)
	var _land = [], _nb = "";
	for (var _ei = 0; _ei < array_length(_rg.edges); _ei++) {
		var _ed = _rg.edges[_ei];
		var _o = (_ed.a == _ni) ? _ed.b : ((_ed.b == _ni) ? _ed.a : -1);
		if (_o < 0) continue;
		var _ok = _rg.nodes[_o].kind, _okd = _kk[$ _ok];
		if (is_struct(_okd) && _okd.wild) array_push(_land, _ok);
		if (_ok == "mine") array_push(_land, "mine");
		if (is_struct(_okd) && _okd.civ && _nb == "") _nb = _rg.nodes[_o].name;
	}
	if (_nb == "") for (var _i = 0; _i < array_length(_rg.nodes); _i++) { if (_i == _ni) continue; var _ikd = _kk[$ _rg.nodes[_i].kind] ?? _kk.field; if (_ikd.civ) { _nb = _rg.nodes[_i].name; break; } }
	if (_nb == "") _nb = "the landing";
	var _rows = [], _desc = "", _lore = "", _facv = "", _foev = "";   // (the faction and its foe, for the region's villain - 2026-09-16)
	var _who = ["miller", "tanner", "widow", "soldier", "priest", "thief", "shepherd", "potter", "exile", "smith", "ferryman", "midwife", "drover", "clerk"];
	var _when = ["three generations back", "a hundred years ago", "longer ago than anyone remembers", "in the old king's time", "the year of the long frost", "before the road came", "when the river ran the other way"];
	switch (_nd.kind) {
		case "settlement": case "village": case "town": case "city": {
			// POPULATION by size, ECONOMY off the land and a tone
			var _pop;
			switch (_nd.kind) {
				case "settlement": _pop = _rng(18, 90, 1, _seed, _base); break;
				case "village":    _pop = _rng(12, 60, 1, _seed, _base) * 10; break;
				case "town":       _pop = _rng(7, 35, 1, _seed, _base) * 100; break;
				default:           _pop = _rng(5, 40, 1, _seed, _base) * 1000; break;
			}
			array_push(_rows, { k : "population", v : "about " + _fmt(_pop), col : undefined });
			var _trade = "";
			var _tp = { field : ["grain", "barley and hay", "cattle", "orchards", "geese"], forest : ["timber", "charcoal", "pitch and resin", "furs", "honey"],
			            hills : ["wool", "quarried stone", "goats", "cheese"], mountains : ["ore", "slate", "goats", "ice"], marsh : ["reeds", "eels", "peat", "willow"],
			            desert : ["salt", "glass", "dates", "dyes"], tundra : ["furs", "oil", "bone", "sledges"], coast : ["fish", "salt", "ships' stores", "rope"],
			            isle : ["fish", "pearls", "seabird eggs"], mine : ["ore", "smelting", "picks and lamps"] };
			if (array_length(_land) > 0) { var _lk = _pick(_land, 2, _seed, _base); _trade = _pick(_tp[$ _lk] ?? ["barter"], 3, _seed, _base); }
			else _trade = _pick(["barter", "a little of everything", "the road's custom", "carting", "whatever comes by"], 3, _seed, _base);
			var _tone;
			switch (_nd.kind) {
				case "settlement": _tone = _pick(["scraping by", "poor", "getting by", "modest", "steady"], 4, _seed, _base); break;
				case "village":    _tone = _pick(["poor", "getting by", "modest", "steady", "busy"], 4, _seed, _base); break;
				case "town":       _tone = _pick(["getting by", "modest", "steady", "busy", "prosperous"], 4, _seed, _base); break;
				default:           _tone = _pick(["steady", "busy", "prosperous", "rich", "fat on trade"], 4, _seed, _base); break;
			}
			array_push(_rows, { k : "economy", v : _trade + ", " + _tone, col : undefined });
			array_push(_rows, { k : "shop", v : _sign + " (" + _n3 + ")", col : undefined });   // (the sign and its keeper - the recurring folk, 2026-09-16)
			// the description: where it sits, what you notice
			var _verb  = _pick(["sits", "huddles", "stands", "spreads", "crouches", "clings on"], 5, _seed, _base);
			var _where = _pick(["at a bend in the road", "at a crossroads", "at a ford", "at the foot of a hill", "along a long green", "by an old stone bridge", "on a dry rise", "at the edge of the woods", "on a slow river", "inside a walled yard", "in a ring of old stones", "where two streams meet"], 6, _seed, _base);
			var _det   = _pick(["thatch roofs and one stone inn", "slate roofs, black in the rain", "smoke over it most evenings", "a market on the green two days in seven", "dogs at every door", "a bell that rings the hours", "walls half fallen and never mended", "a well in the square", "geese in the lanes", "a mill wheel turning", "shutters painted blue", "a gallows nobody uses", "the smell of tanning", "lamps lit at dusk", "washing on every line"], 7, _seed, _base);
			_desc = _verb + " " + _where + "; " + _det;
			if (_nd.kind == "town" || _nd.kind == "city") _desc += ", " + _pick(["gates shut at nightfall", "guild halls on the square", "a bridge with houses on it", "beggars and bankers side by side", "spires you see from the road", "a watch that wants paying", "three inns and a bath-house", "carts queued at the gate by dawn"], 8, _seed, _base);
			// the lore
			var _lt = _rng(0, 8, 9, _seed, _base);
			switch (_lt) {
				case 0: _lore = "founded by " + _n1 + " the " + _pick(_who, 10, _seed, _base) + ", " + _pick(_when, 11, _seed, _base); break;
				case 1: _lore = _n1 + " hanged a " + _pick(["kettle", "boot", "wolf's head", "bell", "sword", "wedding ring"], 10, _seed, _base) + " from the " + _pick(["inn sign", "bridge", "well-beam", "gate", "old oak"], 11, _seed, _base) + " and nobody has taken it down"; break;
				case 2: _lore = "the well went dry the year " + _n1 + " was born and came back the day " + _pick(["she", "he"], 10, _seed, _base) + " left"; break;
				case 3: _lore = "a bell lies buried under the green since the last war; nobody digs for it"; break;
				case 4: _lore = "every child here is told " + _n1 + " still walks the " + _pick(["lanes", "green", "bridge", "wall", "riverbank"], 10, _seed, _base) + " at dusk"; break;
				case 5: _lore = "it burned once, they say, and was built again in a season"; break;
				case 6: _lore = "the " + _trade + " here was once sold as far as " + _pick(["the coast", "the capital", "the far side of the mountains", "the islands", "the salt towns"], 10, _seed, _base); break;
				case 7: _lore = "the elder, " + _n1 + ", has not been seen since the " + _pick(["storm", "fair", "flood", "eclipse", "wedding"], 10, _seed, _base); break;
				default: _lore = _n1 + " and " + _n2 + " quarrelled over a " + _pick(["field", "goat", "boundary stone", "song", "bridge toll"], 10, _seed, _base) + " " + _pick(_when, 11, _seed, _base) + "; their families still do not speak"; break;
			}
			break;
		}
		case "dungeon": case "crypt": case "sewer": {
			var _cr = (_nd.kind == "crypt"), _sw = (_nd.kind == "sewer");
			array_push(_rows, { k : "rooms", v : string(_cr ? _rng(5, 12, 1, _seed, _base) : _rng(4, 9, 1, _seed, _base)), col : undefined });
			// the faction: named off the foes that haunt it
			var _fk = foe_kinds_at(_nd.kind);
			var _foe = _pick(_fk, 2, _seed, _base);
			var _fac = "the " + str_cap(_pick(["red", "black", "hollow", "broken", "grey", "salt", "moon", "iron", "bone", "rat", "cold", "ash", "blind"], 3, _seed, _base)) + " " + str_cap(foe_plural(_foe));
			array_push(_rows, { k : "held by", v : _fac, col : c_hred });
			_facv = _fac; _foev = _foe;
			array_push(_rows, { k : "depth", v : _pick(["shallow", "two levels", "three levels", "deeper than the map", "one long hall", "stairs that keep going"], 4, _seed, _base), col : undefined });
			if (_sw) _desc = _pick(["a grate in the street", "a culvert under the wall", "a hatch behind the tannery", "an arch where the river goes in", "a manhole with a ring in it"], 5, _seed, _base) + "; " + _pick(["the smell arrives first", "warm air coming up", "a rat watching from the dark", "the town's whole weather, underneath", "water you can hear but not see"], 7, _seed, _base);
			else if (_cr) _desc = _pick(["a slab", "a sunken door", "a barrow mouth", "a chapel floor", "an iron gate"], 5, _seed, _base) + " " + _pick(["in a field of stones", "under a yew", "at the crossroads", "beneath the old chapel", "in the side of a mound"], 6, _seed, _base) + "; " + _pick(["cold as a well", "candles nobody lit", "the dead do not lie still", "names worn off every stone", "a smell of old flowers"], 7, _seed, _base);
			else     _desc = _pick(["a doorway", "a stair", "an iron grate", "a cave mouth", "a cellar hatch", "a cleft in the rock"], 5, _seed, _base) + " " + _pick(["in a hillside", "under an old tower", "behind a waterfall", "at the back of a quarry", "under the roots of a dead oak", "in the bank of the river"], 6, _seed, _base) + "; " + _pick(["torchlight inside", "a draught that smells of iron", "bones at the threshold", "drums some nights", "scratched marks by the door", "water on the floor"], 7, _seed, _base);
			var _lt2 = _rng(0, 5, 9, _seed, _base);
			switch (_lt2) {
				case 0: _lore = "sealed by " + _n1 + "'s order after the third party never came out"; break;
				case 1: _lore = _fac + " took it from " + _pick(["the wolves", "a coven", "the old garrison", "a family of hermits", "whoever built it"], 10, _seed, _base) + " a winter ago"; break;
				case 2: _lore = "a " + _pick(_who, 10, _seed, _base) + " from " + _nb + " went in with a lantern and came out with a limp and a purse"; break;
				case 3: _lore = "it was a mine once, they say, until the diggers hit something"; break;
				case 4: _lore = "there is a chamber nobody has found, the story goes, with " + _n1 + "'s " + _pick(["crown", "sword", "ledger", "bones", "hoard"], 10, _seed, _base) + " in it"; break;
				default: _lore = "the door was open when " + _n2 + " came by; it was shut when " + _pick(["she", "he"], 10, _seed, _base) + " came back"; break;
			}
			break;
		}
		case "camp": {
			array_push(_rows, { k : "bandits", v : _pick(["a handful", "a dozen", "a score", "more than a score", "fewer than they say"], 1, _seed, _base), col : c_hred });
			// (the chief is region_node_leader's now - a month or two each, bounty hunters being what they are; 2026-09-16)
			_facv = _n1 + "'s bandits"; _foev = "bandit";
			array_push(_rows, { k : "chest", v : _pick(["light", "heavy", "rumoured full", "buried, they say", "two of them"], 3, _seed, _base), col : c_gold });
			_desc = "tents " + _pick(["in a hollow", "under the trees", "on a spur above the road", "in a ruined steading", "behind a palisade", "in an old quarry"], 5, _seed, _base) + "; " + _pick(["a lookout on a rock", "smoke by day, fires by night", "dogs", "carts they took, stripped to the axles", "a flag that used to be a shirt", "the smell of roasting goat"], 6, _seed, _base);
			var _lt3 = _rng(0, 4, 9, _seed, _base);
			switch (_lt3) {
				case 0: _lore = _n1 + " was a soldier once, before the pay stopped"; break;
				case 1: _lore = "they rob the road one week in three and drink the rest"; break;
				case 2: _lore = "the camp moved here when the last one was burned"; break;
				case 3: _lore = "half of them are farmers' sons from " + _nb; break;
				default: _lore = _n2 + " left them last spring and took the good horse"; break;
			}
			break;
		}
		case "ruin": {
			array_push(_rows, { k : "age", v : _pick(["old", "very old", "older than the road", "from the tower-builders' time", "nobody can say"], 1, _seed, _base), col : undefined });
			array_push(_rows, { k : "standing", v : _pick(["a wall and a hearth", "three arches", "the floor only", "a tower to the second storey", "steps to nowhere", "a gate with no wall"], 2, _seed, _base), col : undefined });
			_desc = _pick(["ivy over everything", "stones the size of carts", "a carved face on the lintel", "sheep graze inside it", "the roof is the sky"], 5, _seed, _base) + "; " + _pick(["finds turn up after rain", "nothing grows in the middle", "the road bends to avoid it", "it hums in a high wind"], 6, _seed, _base);
			_lore = _pick(["a hall stood here; whose, nobody agrees", "the stones were carted off for " + _nb + " years ago", "children dare each other to sleep here", _n1 + " found a ring here and was never poor again", "it was a temple, or a granary, or both"], 9, _seed, _base);
			break;
		}
		case "shrine": {
			var _asp = "the " + str_cap(_pick(["quiet", "third", "last", "kind", "long", "white", "sleeping", "far", "patient", "open"], 1, _seed, _base)) + " " + str_cap(_pick(["hand", "moon", "road", "lantern", "hour", "ford", "well", "wind", "door", "thread"], 2, _seed, _base));
			array_push(_rows, { k : "to", v : _asp, col : c_lavender });
			array_push(_rows, { k : "kept by", v : _pick(["nobody", "an old woman", "a boy from " + _nb, "the road itself", "whoever passes", _n1 + ", who never speaks"], 3, _seed, _base), col : undefined });
			_desc = _pick(["a niche in a standing stone", "a little roof on four posts", "a spring in a stone basin", "a tree hung with ribbons", "a cairn with a bowl on top"], 5, _seed, _base) + "; " + _pick(["coins in the moss", "a candle always lit", "the water is very cold", "birds do not sing here", "it is warmer than it should be"], 6, _seed, _base);
			_lore = _pick(["leave a coin and take a stone, that is the custom", "the shrine was moved once and the river moved after it", _n1 + " was cured here of something nobody names", "on the longest night the whole of " + _nb + " walks out to it", "a traveller who mocked it walked in circles for a day"], 9, _seed, _base);
			break;
		}
		case "mine": {
			array_push(_rows, { k : "ore", v : ["ferrite", "bloom", "glass"][_d.biome mod 3], col : c_steelblue });
			array_push(_rows, { k : "worked", v : _pick(["abandoned", "a few diggers", "by " + _nb, "in the season only", "at night, they say"], 2, _seed, _base), col : undefined });
			array_push(_rows, { k : "shafts", v : string(_rng(1, 4, 3, _seed, _base)), col : undefined });
			_desc = _pick(["timbered mouth in a bank", "a wheel-house and a spoil heap", "rails into the dark", "a ladder down a hole", "a cut in the hillside"], 5, _seed, _base) + "; " + _pick(["the dark begins at the door", "a drip you can set a clock by", "picks left where they fell", "a smell of wet iron", "bats at dusk"], 6, _seed, _base);
			_lore = _pick(["the deep shaft flooded the year the diggers struck water", "a vein of something brighter was found and lost again", _n1 + " went down with a lamp and sang the whole way; nobody knows why", "the diggers' wages were paid in " + _pick(["salt", "beer", "promises"], 10, _seed, _base), "there is a door down there, the old men say, that was not dug"], 9, _seed, _base);
			break;
		}
		case "landing": {
			array_push(_rows, { k : "ground", v : _pick(["flat and firm", "a shingle bank", "a cropped meadow", "a bare rise"], 1, _seed, _base), col : undefined });
			_desc = "a cairn, a ring of stones, and the road home";
			_lore = "the first crew to land here left a cairn; every crew since has added a stone";
			break;
		}
		default: {
			// the wild: the going, what is found, the foes (the card adds them)
			var _gp = { field : ["easy", "open", "muddy after rain"], forest : ["slow", "tangled", "a good path"], hills : ["steep in places", "a long climb", "sheep tracks"],
			            marsh : ["boggy", "planks and luck", "wet to the knee"], desert : ["hot", "soft sand", "hard pan"], mountains : ["hard", "a pass", "scree"],
			            tundra : ["frozen", "wind", "firm"], coast : ["shingle", "cliffs", "sand at low tide"], isle : ["by boat", "rocks", "a landing at low water"] };
			var _fp = { field : ["herbs", "hares", "flint"], forest : ["mushrooms", "resin", "firewood"], hills : ["wool on the thorns", "stones", "a view"],
			            marsh : ["reeds", "eels", "a lost boot"], desert : ["glass", "salt", "bones"], mountains : ["ore", "ice", "eagles' feathers"],
			            tundra : ["bone", "lichen", "furs"], coast : ["shells", "driftwood", "a wreck's timbers"], isle : ["eggs", "shells", "pearls"] };
			var _dp = { field : ["long grass to the hip; larks", "stubble and stone walls", "a field gone to thistle", "hay in stooks", "a scarecrow with a good coat"],
			            forest : ["oak and holly, close", "pines, and needles underfoot", "a wood with a path through it", "birches, white in any light", "a wood that drips after rain"],
			            hills : ["round hills, sheep-bitten", "a ridge with a wind on it", "bracken and old walls", "a hill with a stone on top"],
			            marsh : ["reeds higher than a man", "black water and green weed", "a causeway, half sunk", "mist most mornings"],
			            desert : ["dunes and one thorn tree", "flat, cracked, shimmering", "red rock and no shade", "wind and a dry well"],
			            mountains : ["a pass between two peaks", "scree and snow above", "a col with a cairn", "cliffs and a thin path"],
			            tundra : ["frozen ground, low sun", "lichen and stones", "snow crusted hard", "a lake iced over"],
			            coast : ["cliffs and a shingle beach", "dunes and marram grass", "rock pools and a wreck", "a cove with a cave"],
			            isle : ["a rock with birds on it", "a green island, no trees", "a harbour and three huts", "cliffs all round but one landing"] };
			array_push(_rows, { k : "going", v : _pick(_gp[$ _nd.kind] ?? ["fair"], 1, _seed, _base), col : undefined });
			array_push(_rows, { k : "finds", v : _pick(_fp[$ _nd.kind] ?? ["little"], 2, _seed, _base), col : c_sgreen });
			_desc = _pick(_dp[$ _nd.kind] ?? ["the road passes through"], 5, _seed, _base);
			var _lt4 = _rng(0, 5, 9, _seed, _base);
			switch (_lt4) {
				case 0: _lore = "named for " + _n1 + ", a " + _pick(_who, 10, _seed, _base) + " who was struck by lightning here and lived"; break;
				case 1: _lore = "a battle was fought here " + _pick(_when, 10, _seed, _base) + "; the plough still turns up buckles"; break;
				case 2: _lore = "it floods every seventh spring, or so " + _nb + " says"; break;
				case 3: _lore = "a stone stands here that nobody put up"; break;
				case 4: _lore = "travellers leave the road here and are never quite where they meant to be"; break;
				default: _lore = _n1 + " and " + _n2 + " were married here, under the open sky, " + _pick(_when, 10, _seed, _base); break;
			}
			break;
		}
	}
	_nd.card = { rows : _rows, desc : _desc, lore : _lore, folk : { elder : _n1, other : _n2, keeper : _n3, trader : _n4 }, shop : _civ ? { sign : _sign } : undefined, fac : _facv, foe : _foev };
	return _nd.card;
}
