/// the ability deck's room controller, ported from Myriad DE with its
/// native architecture intact:
///  - the deck is DECLARED in the grab_deck batch scripts; slots and
///    this controller are both "lenses" pointed at an index. the
///    controller's own `a` is the INSPECTED card - its full pass
///    (a_ = -1) reseeds the batch offsets and materializes the
///    selection for the info panel in one sweep
///  - toggles write back through return_deck (the ability() mirror)
///  - AP is an enable budget recomputed whole by grab_deck_ap
///  - discovery: units buy a seeded draw from the eligible pool
///    (fetch_new_ability - the pool is an array now, not a txt file)
/// what changed: input is arbitrated (region pattern), the info panel
/// crossfade kept but on one i_/o_ set, UI rebuilt for 480x270

// ---- layout: scrollbar hugging the LEFT edge, list beside it,
// info column right (house style). the list stops ABOVE the debug
// row so slots never pass behind the bottom buttons ----
row_h  = 15;
list_x = 12;
list_y = 42;
list_w = 234;
visible_rows = 13;
info_x = 256;
info_w = room_width - 6 - info_x;
info_y = 58;

can_edit = true; // Myriad locked editing later in a run; the seam stays

// rebuild flags (native protocol: grab_deck decrements input_changed)
update_ap     = true;
input_changed = 2;
mx = 0;      // visible row count, set by grab_deck_ap (scrollbar range)
a  = -1;     // the inspected index (-1 = nothing: the how-to card)
a_ = -1;     // controller passes are always full passes
previous_a = -999;
shown_aid  = -2; // which aid the info panel currently shows

g.ability_page = 0;

// batch offsets (grab_deck memoizes section boundaries here)
batch_survey  = 0;
batch_fleet   = 0;
batch_tiles   = 0;
batch_colony  = 0;
batch_combat  = 0;
batch_support = 0;

// slot-protocol vars this controller shares with obj_ability_slot
// (grab_deck materializes the selection into these)
aid = -1;
input = -1;
name = "ability deck";
apreq = 0;
rarity = 0;
txt = "";
sub = false;
open = true;
_open = true;
tog = true;
flavor = 0;
f = 0;
repeat (5) { flavor_text[f] = ""; flavor_color[f] = c_white; f++; }

// ---- info panel crossfade (native i_ = incoming, o_ = outgoing) ----
i_name = "ability deck";
i_text = "tap an ability to read it.\ntap its ap chip to toggle it.\ndiscover new abilities below.";
i_rarity = -1;
i_apreq = 0;
i_flavor = 0;
o_name = ""; o_text = ""; o_rarity = -1; o_apreq = 0; o_flavor = 0;
i_tos = 0;  o_tos = 0;
i_alpha = 1; o_alpha = 0;
f = 0;
repeat (5) {
	i_flavor_text[f] = ""; i_flavor_color[f] = c_white;
	o_flavor_text[f] = ""; o_flavor_color[f] = c_white;
	f++;
}

// discovery reveal flash
reveal_name = "";
reveal_rtxt = "";
reveal_col  = c_white;
reveal_t    = 0;

// ---- collection view (view 1): every card in deck order, the
// undiscovered as ??? silhouettes. rows mirror the batches - keep
// this section map in sync when the deck changes ----
view = 0;
coll_rows = [];
var _secs = [
	["survey",  ["ad_probespeed", "ad_probespeed2", "ad_multiprobe",
		"ad_deepscan", "ad_autosurvey"]],
	["fleet",   ["ad_warptune", "ad_fuelcells", "ad_autopilot", "ad_deepspace"]],
	["tiles",   ["ad_automerger", "ad_automerger2", "ad_fabricator",
		"ad_fabricator2", "ad_duplicator", "ad_tilerarity", "ad_hotswap"]],
	["colony",  ["ad_cityloans", "ad_nightshift", "ad_census", "ad_terraformer"]],
	["combat",  ["ad_initiative", "ad_counterschool", "ad_fieldmedic", "ad_warcry"]],
	["support", ["ad_onefinger", "ad_autobuy", "ad_aputilizer", "ad_luckcharm",
		"ad_notekeeper", "ad_bargain", "ad_deeppockets", "ad_scholar"]],
];
for (var _s = 0; _s < array_length(_secs); _s++) {
	array_push(coll_rows, { key : "", title : _secs[_s][0] });
	var _ks = _secs[_s][1];
	for (var _k = 0; _k < array_length(_ks); _k++)
		array_push(coll_rows, { key : _ks[_k], title : "" });
}

// ---- the discovery draft rides the obj_card framework: real 2.5D
// cards, the deck only SUPPLIES face painters and drives rotation.
// nothing ability-flavored lives inside obj_card itself ----
draft_ids = [];
rcol_tab = [c_white, rgb(60, 255, 69), rgb(65, 122, 255),
	rgb(255, 167, 10), rgb(160, 32, 255)];

// face painters, bound onto each spawned card (self = the card;
// content rides card.face = { name, rword, desc, ap, col })
__deck_card_face = function() {
	draw_clear_alpha(c_black, 1);
	// rarity wash from the top of the face
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, 0, 0, card_w, card_h, 0,
		merge_colour(face.col, c_black, .72), merge_colour(face.col, c_black, .72),
		c_black, c_black, 1);
	draw_px_rect(1, 1, card_w - 2, card_h - 2, face.col, .9);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(face.col);
	draw_set_alpha(1);
	// fit-scale long names (Myriad's rule)
	var _sw = string_width(face.name);
	var _sc = (_sw > card_w - 8) ? (card_w - 8) / _sw : 1;
	draw_text_transformed(card_w * .5, 8, face.name, _sc, _sc, 0);
	draw_set_font(fnt);
	draw_set_alpha(.7);
	draw_text(card_w * .5, 22, face.rword);
	// desc: WORD-WRAPPED to the card at scale 1. (fractional sprite-
	// font scaling is what mushed the longer descriptions - the mesh
	// got blamed, but the text was pre-shredded on the surface)
	draw_set_color(c_white);
	draw_set_alpha(.92);
	var _words = string_split(string_replace_all(face.desc, "\n", " "), " ");
	var _line = "";
	var _ly2 = 42;
	for (var _w2 = 0; _w2 < array_length(_words); _w2++) {
		var _try = (_line == "") ? _words[_w2] : _line + " " + _words[_w2];
		if (string_width(_try) > card_w - 10 && _line != "") {
			draw_text(card_w * .5, _ly2, _line);
			_ly2 += 9;
			_line = _words[_w2];
		} else _line = _try;
	}
	if (_line != "") draw_text(card_w * .5, _ly2, _line);
	draw_set_color(c_ap);
	draw_set_alpha(.95);
	draw_text(card_w * .5, card_h - 26, "ap " + string(face.ap));
	draw_set_color(c_gold);
	draw_set_alpha(.75);
	draw_text(card_w * .5, card_h - 13, "claim");
	draw_set_halign(fa_left);
	draw_set_alpha(1);
};
__deck_card_back = function() {
	draw_clear_alpha(rgb(12, 22, 36), 1);
	draw_px_rect(1, 1, card_w - 2, card_h - 2, c_steelblue, .8);
	draw_px_rect(5, 5, card_w - 10, card_h - 10, c_steelblue, .3);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(c_steelblue);
	draw_set_alpha(.9);
	draw_text(card_w * .5, card_h * .5 - 5, "?");
	draw_set_halign(fa_left);
	draw_set_alpha(1);
};

// spawn one obj_card per draft candidate: back showing, staggered
// flip reveal, the deck's Step drives hover tilt
__draft_spawn = function() {
	for (var _i = 0; _i < array_length(draft_ids); _i++)
		if (instance_exists(draft_ids[_i])) instance_destroy(draft_ids[_i]);
	draft_ids = [];
	// fresh entropy for the finish rolls: the ambient RNG stream is
	// deterministic per boot, which is why the finishes repeated.
	// stream restored after (house rule)
	var _rs = random_get_seed();
	randomize();
	var _n = array_length(g.abi_draft);
	for (var _i = 0; _i < _n; _i++) {
		var _ci = deck_card_info(g.abi_draft[_i]);
		var _rw2 = "common";
		if (_ci.rarity == 1) _rw2 = "uncommon";
		if (_ci.rarity == 2) _rw2 = "rare";
		if (_ci.rarity == 3) _rw2 = "legendary";
		if (_ci.rarity == 4) _rw2 = "epic";
		var _c = create_obj(240 - (_n - 1) * 54 + _i * 108, 148, obj_card);
		_c.depth = -50;  // above the modal backdrop (controller depth 0)
		_c.auto  = false; // the deck drives it
		_c.face  = { name : _ci.name, rword : _rw2, desc : _ci.desc,
			ap : _ci.ap, col : rcol_tab[clamp(_ci.rarity, 0, 4)] };
		_c.draw_front_content = method(_c, __deck_card_face);
		_c.draw_back_content  = method(_c, __deck_card_back);
		_c.rot_y = 180;               // face down: the reveal is a flip
		_c.flip_delay = 14 + _i * 10; // staggered left to right
		// DEBUG: random premium finishes to exercise the fx pass.
		// fx is a bitmask, so sometimes two finishes STACK (a
		// rainbow-glitter is a real pull)
		var _fx = 0;
		if (random(1) < .7) {
			var _flags = [1, 2, 4, 8, 16, 32];
			_fx = _flags[irandom(5)];
			if (random(1) < .3) _fx |= _flags[irandom(5)];
		}
		_c.fx = _fx;
		_c.invalidate_front();
		_c.invalidate_back();
		array_push(draft_ids, _c);
	}
	random_set_seed(_rs);
};

// loadout presets: [set] arms the next slot tap to STORE instead of
// apply. overwriting an occupied slot confirms through a pillbox
lo_set = false;
pending_lo = -1;
pill_kind = "";
_popen = false;
_pselid = -1;
_pselname = "";
_pselval = 0;
_pills = [];

// ---- counts + cost fresh (also builds the pool), then the first
// full pass seeds batch offsets and the AP pool ----
fetch_new_ability();
grab_deck();
grab_deck_ap();

// ---- the furniture: scrollbar + the first list slot (it chain-
// spawns the rest, native style) ----
var _sb = create_obj(1, list_y, obj_scrollbar);
_sb.i = scrl_abilitydeck;
_sb.image_yscale = (visible_rows * row_h) / sprite_get_height(spr_scrollbar);

var _sl = create_obj(list_x, list_y, obj_ability_slot);
_sl.a_ = 0;
