/// @description TierKeep() - THE ZOOM TIERS' KEEPER (q216: out of syst_exped_panel, where it lived as eight methods and three instance variables): the page's world's 3x tier (cur / seed, planet_lod_begin's struct), and a keep of four more so a world seen before has its tier at once
/// The tier is the WHOLE map at 3x its resolution (planet_lod_begin /
/// planet_lod_step), built once a world as soon as its base map stands,
/// on a slice a frame - a smaller one under the camera's hand (q202a) -
/// and under a new world's loading veil rushed (q202). A tier the gpu
/// dropped is re-uploaded from its kept buffers. Leaving the world stashes
/// its tier (drop); coming back takes it (take). The panel decides WHEN
/// the tier shows (its zoom) and hands the world and the hand's state in
function TierKeep() constructor {
	cur = undefined;   // the page's world's tier
	seed = -1;         // ...whose world it is
	keep = [];         // [{ seed, l }] the others, newest first, four at most
	/// a tier into the keep (the oldest let go past four)
	static stash = function(_l, _seed) {
		if (!is_struct(_l)) return;
		for (var _i = 0; _i < array_length(keep); _i++) if (keep[_i].seed == _seed) { keep[_i].l = _l; return; }
		array_insert(keep, 0, { seed : _seed, l : _l });
		while (array_length(keep) > 4) { var _old = array_pop(keep); planet_lod_free(_old.l); }
	};
	/// a kept tier out of the keep (undefined when none)
	static take = function(_seed) {
		for (var _i = 0; _i < array_length(keep); _i++) if (keep[_i].seed == _seed) { var _l = keep[_i].l; array_delete(keep, _i, 1); return _l; }
		return undefined;
	};
	/// the page's tier into the keep, not freed
	static drop = function() { if (is_struct(cur)) stash(cur, seed); cur = undefined; seed = -1; };
	/// everything let go (the panel's CleanUp)
	static free_all = function() { drop(); for (var _i = 0; _i < array_length(keep); _i++) planet_lod_free(keep[_i].l); keep = []; };
	/// true once the world's tier stands
	static ready = function(_pn) { return is_struct(_pn) && seed == _pn.seed && is_struct(cur) && cur.ready; };
	/// the tier for the draw when it stands and is wanted (undefined otherwise; a tier the gpu dropped waits for the step's re-upload - never inside a page's target)
	static pick = function(_pn, _wanted) {
		if (!_wanted || seed != _pn.seed || !is_struct(cur) || !(cur.ready || (cur[$ "partial"] ?? false))) return undefined;   // (a partial tier shows what it has - q270)
		if (!surface_exists(cur.tsurf) || !surface_exists(cur.hsurf)) return undefined;
		return cur;
	};
	/// a slice of the build for the world (pn baked already, else nothing); hand = the camera is under the hand (a smaller slice)
	static step = function(_pn, _hand, _until = undefined, _focus = undefined) {   // (until: a caller's own deadline - the background share behind another page, q256; focus: the map v the camera looks at - the rows build nearest it first, q270)
		if (!is_struct(_pn) || _pn.row < _pn.th || (_pn[$ "brow"] ?? 0) < 3 * _pn.th) return;
		if (seed != _pn.seed) { drop(); seed = _pn.seed; cur = take(_pn.seed); }
		if (is_struct(cur) && cur.ready) { if (!surface_exists(cur.tsurf) || !surface_exists(cur.hsurf)) planet_lod_upload(cur); return; }
		if (!is_struct(cur)) cur = planet_lod_begin(_pn, 3);
		if (!is_undefined(_focus) && abs((cur[$ "focus_v"] ?? .5) - _focus) > .05) planet_lod_focus(cur, _focus);   // (the focus moved a twentieth of the map: the rows to come re-sorted - q270)
		// a share of the frame, whatever the refresh rate (delta = the frame in sixtieths): four tenths, 1.5 to 6 ms; under the
		// hand fifteen hundredths, .6 to 1.5 ms - never nothing
		if (is_undefined(_until)) _until = get_timer() + (_hand ? clamp(delta * 16667 * .15, 600, 1500) : clamp(delta * 16667 * .4, 1500, 6000));
		planet_lod_step(_pn, cur, _until);
	};
	/// the build's progress for a veil, 0..1
	static progress = function(_pn) { return (is_struct(cur) && seed == _pn.seed) ? cur.row / max(1, cur.h) : 0; };
}
