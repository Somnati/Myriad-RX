/// syst_scene_light - THE ROOM'S LIGHT ON THE SOLIDS (his brother's
/// argument, 2026-09-11: the visualiser does not light the dice; now it
/// does). Every frame in the money room, at depth SCENE_LIGHT_DEPTH -
/// after the field, its glow pass and the vignette (the layers at 40 /
/// 30 / 20) and BEFORE the dice (10), the puck (9) and the sprites - it
/// copies the application surface, half size, and halves it down a
/// chain (the blur chain's law: halving is the one ratio at which
/// bilinear averages honestly). Two links are kept as textures:
///   tight   a fifth of room resolution - a few room px of blur, what a
///           glossy thing REFLECTS
///   wide    a thirtieth - the wash of colour around a thing, what a
///           matte thing is LIT by
/// sh_dice, sh_puck and sh_blob take both as samplers (scene_light_bind)
/// and each raycast pixel reads the screen a little way along its own
/// normal - a face turned toward a bright block takes that block's
/// colour. Ambient, not a light source: no shadows, no direction beyond
/// the normal's lean; it reads as spill, which is what the eye expects
/// from a solid beside a lamp.
///
/// Draw order is what keeps a thing from lighting itself: the capture
/// happens before the solids draw, so the dice see the field and each
/// other's last frame never. Settings > visuals "scene light" is the
/// strength (0 = off, and nothing here runs).

#macro SCENE_LIGHT_DEPTH 15
depth = SCENE_LIGHT_DEPTH;
persistent = true;

ready = false;     // a capture happened this frame (the Step clears it)
chain = [];        // the halvings, half size down to a thirty-second
ckey  = "";        // (not `key` - that is a house macro for keyboard_check)
tight = -1;        // the two links the shaders read
wide  = -1;

/// (re)build the chain for an application surface of _w x _h
__build = function(_w, _h) {
	var _k = string(_w) + "x" + string(_h);
	var _ok = (ckey == _k) && (array_length(chain) == 6);
	if (_ok) for (var _i = 0; _i < 6; _i++) if (!surface_exists(chain[_i])) { _ok = false; break; }
	if (_ok) return true;
	for (var _i = 0; _i < array_length(chain); _i++)
		if (surface_exists(chain[_i])) surface_free(chain[_i]);
	chain = [];
	var _cw = _w, _ch = _h;
	for (var _i = 0; _i < 6; _i++) {
		_cw = max(1, _cw div 2); _ch = max(1, _ch div 2);
		array_push(chain, surface_create(_cw, _ch));
	}
	ckey = _k;
	return true;
};
