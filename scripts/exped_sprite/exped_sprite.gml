/// @description exped_sprite(id) -> the sprite struct, or undefined
function exped_sprite(_id) {
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _id) return g.sprites[_i];
	return undefined;
}
