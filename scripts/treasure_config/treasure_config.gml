/// @description treasure_config() -> the TREASURES (his ask, 2026-09-17:
/// "treasures that they can sell - silver ring, gold nugget, amethyst gem,
/// a frayed knot"): things a crew finds that are for nothing but selling.
/// Each kind has three names by the find's rarity - the low rungs, the
/// middle, the high - and a base value in credits at common
/// (treasure_gen scales it by the rarity and the world's tier). Sold at
/// any shop the crew visits (exped_shop, first over the counter) or at the
/// door coming home (exped_tick_one). APPEND ONLY: a saved treasure's seed
/// picks by index.
function treasure_config() {
	static _c = [
		{ key : "knot", names : ["a frayed knot", "a frayed knot", "a frayed knot"], val : 1, col : rgb(150, 140, 130) },   // (the pun, at every rung - "afraid not"; his call 2026-09-17)
		{ key : "button", names : ["a button", "a brass button", "a jewelled button"], val : 1, col : rgb(190, 120, 80) },
		{ key : "marble", names : ["a marble", "a cat's-eye marble", "a shooter marble"], val : 1, col : rgb(200, 220, 240) },
		{ key : "nail", names : ["a bent nail", "a horseshoe nail", "a golden nail"], val : 1, col : rgb(150, 140, 130) },
		{ key : "sock", names : ["a sock", "a lucky sock", "the other sock"], val : 1, col : rgb(150, 140, 130) },
		{ key : "spoon", names : ["a bent spoon", "a silver spoon", "a gilded spoon"], val : 2, col : rgb(200, 205, 215) },
		{ key : "bead", names : ["a glass bead", "a string of beads", "a jet necklace"], val : 2, col : rgb(120, 110, 220) },
		{ key : "tooth", names : ["a tooth", "a monster's tooth", "a dragon's tooth"], val : 2, col : rgb(220, 210, 190) },
		{ key : "feather", names : ["a feather", "a fine feather", "a phoenix feather (probably)"], val : 2, col : rgb(255, 150, 60) },
		{ key : "shell", names : ["a shell", "a conch", "a nautilus shell"], val : 2, col : rgb(240, 235, 225) },
		{ key : "coin", names : ["an old coin", "a foreign coin", "a coin of the old kingdom"], val : 3, col : rgb(190, 120, 80) },
		{ key : "candle", names : ["a candlestick", "a brass candlestick", "a silver candlestick"], val : 3, col : rgb(200, 205, 215) },
		{ key : "bottle", names : ["a bottle (empty)", "a bottle with a ship in", "a bottle with a message in"], val : 3, col : rgb(200, 220, 240) },
		{ key : "key", names : ["a key to nothing", "an iron key", "a golden key"], val : 3, col : rgb(150, 140, 130) },
		{ key : "ring", names : ["a tin ring", "a silver ring", "a gold ring"], val : 4, col : rgb(200, 205, 215) },
		{ key : "amber", names : ["a lump of amber", "amber with a fly in", "amber with a lizard in"], val : 4, col : rgb(230, 170, 60) },
		{ key : "map", names : ["half a map", "a map of somewhere", "a treasure map (no x)"], val : 4, col : rgb(210, 200, 180) },
		{ key : "fossil", names : ["a fossil", "a fine fossil", "a fossil of something big"], val : 4, col : rgb(220, 210, 190) },
		{ key : "garnet", names : ["a garnet chip", "a garnet", "a blood garnet"], val : 5, col : rgb(160, 40, 60) },
		{ key : "locket", names : ["a locket (empty)", "a silver locket", "a locket with a portrait in"], val : 5, col : rgb(200, 205, 215) },
		{ key : "musicbox", names : ["a music box (broken)", "a music box", "a music box that still plays"], val : 5, col : rgb(170, 120, 70) },
		{ key : "horn", names : ["a horn", "a carved horn", "a unicorn horn (they say)"], val : 5, col : rgb(220, 210, 190) },
		{ key : "nugget", names : ["a copper nugget", "a silver nugget", "a gold nugget"], val : 6, col : c_gold },
		{ key : "amethyst", names : ["a chipped amethyst", "an amethyst gem", "a flawless amethyst"], val : 6, col : rgb(170, 110, 220) },
		{ key : "goblet", names : ["a dented cup", "a silver goblet", "a jewelled chalice"], val : 6, col : rgb(200, 205, 215) },
		{ key : "watch", names : ["a pocket watch (stopped)", "a pocket watch", "a gold pocket watch"], val : 6, col : c_gold },
		{ key : "pearl", names : ["a seed pearl", "a pearl", "a black pearl"], val : 7, col : rgb(240, 235, 225) },
		{ key : "opal", names : ["an opal chip", "an opal", "a fire opal"], val : 7, col : rgb(200, 220, 240) },
		{ key : "jade", names : ["a jade chip", "a jade figurine", "an imperial jade carving"], val : 8, col : rgb(90, 170, 120) },
		{ key : "idol", names : ["a clay idol", "a bronze idol", "a golden idol"], val : 8, col : rgb(170, 120, 70) },
		{ key : "emerald", names : ["a cloudy emerald", "an emerald", "a flawless emerald"], val : 9, col : rgb(60, 190, 110) },
		{ key : "ruby", names : ["a ruby chip", "a ruby", "a pigeon's-blood ruby"], val : 9, col : rgb(220, 40, 70) },
		{ key : "sapphire", names : ["a sapphire chip", "a sapphire", "a star sapphire"], val : 9, col : rgb(60, 100, 220) },
		{ key : "crown", names : ["a paper crown", "a circlet", "a crown"], val : 12, col : c_gold },
		{ key : "diamond", names : ["a rough diamond", "a diamond", "a flawless diamond"], val : 14, col : rgb(220, 240, 255) },
	];
	return _c;
}
