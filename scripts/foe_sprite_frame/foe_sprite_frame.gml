/// @description foe_sprite_frame(kind) -> spr_foe's frame for a foe kind (its name), -1 when unknown
/// THE FOE SPRITES (2026-09-16, his ask: the bestiary showed a letter; "making a whole roster of enemies is a hassle for
/// me"): spr_foe is GENERATED - datafiles/gen_foe_sprites.py draws a 16x16 pixel creature a kind (families by name:
/// quadrupeds, humanoids, blobs, flyers, crawlers, snakes, a robe, an orb), in gray tones with a white eye, one frame
/// per kind in the ALPHABETICAL order of foe_roster's names. Drawn tinted the foe's colour (the variant's lean rides
/// along). Add a kind to the roster = run the generator again (the frames are re-dealt alphabetically).
function foe_sprite_frame(_kind) {
	static _names = undefined;
	if (is_undefined(_names)) {
		var _ros = foe_roster();
		_names = [];
		for (var _i = 0; _i < array_length(_ros); _i++) array_push(_names, _ros[_i].name);
		array_sort(_names, true);
	}
	for (var _i = 0; _i < array_length(_names); _i++) if (_names[_i] == _kind) return _i;
	return -1;
}
