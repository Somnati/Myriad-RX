/// @description gear_families() -> the item families by slot kind
/// Each family: the STAT LINES it carries (weights the item's points are
/// spread over) and its silly NOUNS (his call: Godville-flavoured, not a
/// rip - "pot lid" for a shield). Four slot kinds, his list: w1 the
/// primary weapon, w2 the secondary, armor, talis (a talisman).
function gear_families() {
	static _f = {
		w1 : [
			{ key : "sword", lines : { atk : 3, hit : 1 }, nouns : ["butter knife", "sharpened spoon", "letter opener", "very long nail", "sword-shaped stick", "cutlass (cheap)", "fence picket", "bread knife"] },
			{ key : "axe",   lines : { atk : 4 }, nouns : ["firewood axe", "meat cleaver", "hatchet (borrowed)", "garden hoe", "splitting maul", "chair leg with a nail in"] },
			{ key : "mace",  lines : { atk : 3, def : 1 }, nouns : ["rolling pin", "frying pan", "meat tenderiser", "sock of coins", "table leg", "big spoon"] },
			{ key : "spear", lines : { atk : 2, spd : 1, hit : 1 }, nouns : ["broom with a knife on", "curtain pole", "long fork", "fishing rod (pointy)", "flagpole", "pitchfork"] },
			{ key : "staff", lines : { mag : 3, mp : 1 }, nouns : ["broom handle", "walking stick", "wizard's rake", "big twig", "mop", "curtain rod", "shepherd's crook"] },
			{ key : "wand",  lines : { mag : 2, hit : 2 }, nouns : ["conductor's baton", "pencil", "chopstick", "drumstick", "twig (special)", "knitting needle"] },
			{ key : "bow",   lines : { atk : 2, hit : 2 }, nouns : ["bent stick and string", "crossbow (toy)", "slingshot", "hunting bow", "yew branch", "harp (repurposed)"] },
			{ key : "dagger", lines : { atk : 2, spd : 1, hit : 1 }, nouns : ["paring knife", "shard of something", "hairpin", "cheese knife", "sharp rock", "nail file"] },
			// (the proc-gear pass, 2026-09-15 - APPEND ONLY: a saved item's seed picks by index within its generation's pool)
			{ key : "flail",  lines : { atk : 3, spd : 1 }, nouns : ["ball on a rope", "sock of spuds", "yo-yo (heavy)", "censer (stolen)", "lantern on a chain", "conker (large)"] },
			{ key : "scythe", lines : { atk : 3, hit : 1, mag : 1 }, nouns : ["farm scythe", "sickle", "hedge trimmer", "the reaper's spare", "grass hook", "bent sword"] },
			{ key : "whip",   lines : { hit : 3, spd : 1 }, nouns : ["belt", "rope with a knot", "very long shoelace", "riding crop", "garden hose", "washing line"] },
			{ key : "claws",  lines : { atk : 2, spd : 2 }, nouns : ["garden fork", "rake head", "two forks", "gloves with nails in", "bear paw (glove)", "cutlery (fanned)"] },
			{ key : "orb",    lines : { mag : 3, mdef : 1 }, nouns : ["snow globe", "crystal ball (cracked)", "glass float", "very round stone", "bowling ball", "onion (large)"] },
			{ key : "sling",  lines : { hit : 2, spd : 1, atk : 1 }, nouns : ["sock and a stone", "catapult (toy)", "shoelace and a marble", "elastic and hope", "trebuchet (pocket)"] },
		],
		w2 : [
			{ key : "shield",  lines : { def : 3, mdef : 1 }, nouns : ["pot lid", "cutting board", "serving tray", "stop sign", "manhole cover", "cellar door", "dustbin lid"] },
			{ key : "buckler", lines : { def : 2, spd : 1 }, nouns : ["dinner plate", "hubcap", "frisbee", "saucepan lid", "hat (sturdy)", "book (thick)"] },
			{ key : "dagger",  lines : { atk : 1, spd : 2, hit : 1 }, nouns : ["paring knife", "hairpin", "sharp rock", "corkscrew", "fork", "broken bottle"] },
			{ key : "tome",    lines : { mag : 2, mdef : 2 }, nouns : ["cookbook", "phone book", "diary (locked)", "atlas", "dictionary", "someone's notes"] },
			{ key : "torch",   lines : { mag : 1, hit : 1, spd : 1 }, nouns : ["torch", "candle on a stick", "lantern (dim)", "glowing mushroom", "hot poker"] },
			{ key : "lantern", lines : { mdef : 2, hit : 1 }, nouns : ["lantern", "jar of fireflies", "oil lamp", "lighthouse (small)", "glass with a candle in"] },
			{ key : "horn",   lines : { hit : 1, spd : 1, mp : 1 }, nouns : ["cow horn", "bugle", "kazoo (large)", "trumpet (dented)", "conch", "vuvuzela"] },
			{ key : "bell",   lines : { mdef : 2, hit : 1 }, nouns : ["cowbell", "doorbell", "dinner bell", "bell (no clapper)", "wind chime", "bicycle bell"] },
			{ key : "net",    lines : { spd : 1, hit : 2 }, nouns : ["fishing net", "hairnet", "bag of holes", "tennis net (piece)", "string bag", "hammock"] },
			{ key : "mirror", lines : { mdef : 3 }, nouns : ["hand mirror", "polished tray", "shaving mirror", "puddle (frozen)", "spoon (very large)", "window (piece)"] },
			{ key : "flask",  lines : { mp : 2, hp : 1 }, nouns : ["flask", "hip flask", "thermos", "hot water bottle", "kettle (small)", "gourd"] },
		],
		armor : [
			{ key : "plate",   lines : { def : 4, hp : 2 }, nouns : ["barrel", "stove door", "bath tub", "suit of cutlery", "kettle helm and bits", "cast iron everything"] },
			{ key : "mail",    lines : { def : 3, hp : 1, mdef : 1 }, nouns : ["chain fence", "bead curtain", "net", "coat of bottle caps", "key rings (many)"] },
			{ key : "leather", lines : { def : 2, spd : 2 }, nouns : ["apron", "old saddle", "jacket (cool)", "belt (several)", "boots and confidence"] },
			{ key : "robe",    lines : { mdef : 3, mp : 2, def : 1 }, nouns : ["bathrobe", "bedsheet", "curtain", "very long scarf", "tablecloth", "wizard pyjamas"] },
			{ key : "cloak",   lines : { mdef : 2, spd : 2, hit : 1 }, nouns : ["towel", "cape (homemade)", "tarp", "flag", "blanket", "poncho"] },
			{ key : "hide",    lines : { hp : 3, def : 2 }, nouns : ["rug", "bear (empty)", "welcome mat", "sheepskin", "wet coat", "carpet"] },
			{ key : "quilted", lines : { hp : 3, mdef : 1 }, nouns : ["duvet", "quilt", "padded jacket", "sleeping bag (worn)", "cushions (strapped on)", "oven glove (whole body)"] },
			{ key : "scale",   lines : { def : 3, mdef : 1, hp : 1 }, nouns : ["roof tiles", "coat of spoons", "fish (many)", "pinecones (sewn)", "coins (glued)", "bottle caps (overlapping)"] },
			{ key : "bone",    lines : { def : 2, hp : 2 }, nouns : ["ribcage (someone's)", "antlers and string", "tortoise shell (borrowed)", "bones (assorted)", "skull hat and bits"] },
			{ key : "feathered", lines : { spd : 3, hit : 1 }, nouns : ["feather coat", "chicken suit", "pillow contents", "owl (costume)", "cape of geese", "fan (worn)"] },
			{ key : "wax",     lines : { mdef : 2, hp : 2 }, nouns : ["candle coat", "waxed jacket", "beeswax and hope", "raincoat (melted)", "tallow suit"] },
		],
		talis : [
			{ key : "charm",  lines : { hit : 2, spd : 1 }, nouns : ["lucky sock", "rabbit's foot (fake)", "four-leaf weed", "horseshoe", "bottle cap", "old ticket"] },
			{ key : "amulet", lines : { mdef : 2, mp : 2 }, nouns : ["locket (empty)", "spoon on a string", "pendant", "shell necklace", "key to nothing"] },
			{ key : "ring",   lines : { atk : 1, mag : 1, hit : 1 }, nouns : ["washer", "curtain ring", "onion ring (old)", "wedding ring (not yours)", "keyring"] },
			{ key : "bead",   lines : { hp : 2, mdef : 1 }, nouns : ["marble", "worry stone", "smooth pebble", "bead", "acorn", "tooth (whose?)"] },
			{ key : "idol",   lines : { mag : 2, hp : 1 }, nouns : ["garden gnome", "salt shaker", "figurine", "rubber duck", "small statue of a duck"] },
			{ key : "coin",   lines : { hit : 1, spd : 1, def : 1 }, nouns : ["foreign coin", "button", "medal (participation)", "arcade token", "chocolate coin"] },
			{ key : "feather", lines : { spd : 2, hit : 1 }, nouns : ["goose feather", "quill", "feather (unidentified)", "duster", "the good feather"] },
			{ key : "tooth",   lines : { atk : 2, hp : 1 }, nouns : ["tooth (large)", "fang on a string", "dentures (not yours)", "tusk (small)", "molar (someone's)"] },
			{ key : "bottle",  lines : { mp : 2, mag : 1 }, nouns : ["bottle of something", "ship in a bottle", "message in a bottle", "bottle (empty and still lucky)", "ink pot"] },
			{ key : "key",     lines : { hit : 2, mdef : 1 }, nouns : ["key to nothing", "skeleton key (actual bone)", "keyring (heavy)", "key (bent)", "a key that fits a door somewhere"] },
			{ key : "knot",    lines : { def : 2, hp : 1 }, nouns : ["knot of rope", "friendship bracelet", "shoelace (lucky)", "tangle", "bow (untied)"] },
			{ key : "bone",    lines : { mdef : 2, hp : 1 }, nouns : ["knucklebone", "wishbone", "a small skull", "vertebra", "finger bone (ring-sized)"] },
		],
	};
	return _f;
}
