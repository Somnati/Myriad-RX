/// @description exped_shop(trip) - the crew consults the shops (his pitch: on their own, with their own credits)
/// THE SHOP (the shop-stock pass, 2026-09-15): a place has a shop with a
/// SIGN (generated: "the crooked kettle", "the three pigs", "Orrin's
/// ironmongery" - never a fixed list), and a STOCK by its size - a
/// settlement shows one common thing, a village one or two up to
/// uncommon, a town two up to rare, a city three up to epic. Every member
/// who is up looks the stock over; a thing is bought only if the pocket
/// covers it AND it beats what is worn (gear_score, the class's eye) -
/// then sprite_take handles it, dumb moment included (yes, they can buy
/// it and bin it). A HAGGLE: greedy and sly pay one less, kind pays one
/// more, on purpose. The price 2 + lv/3 + 2 a rung. Whatever is left of
/// the pocket comes home. The stock tastes of the town or the land
/// around it (gear_gen's tag).
/// PHASES (2026-09-16, the town as beats): "open" lays the shelf out and keeps it
/// on the activity (act.shop); "buy" is ONE member's look (k); "close" the
/// SELLING (the pocket's worst, by the stance), the credits joke and the last
/// word; "all" the whole visit in one (the old way, for any other caller).
/// The keeper and the sign are the place's own (region_node_info's folk).
function exped_shop(_tr, _phase = "all", _k = -1) {
	var _rg = exped_region(_tr);
	var _nd = _rg.nodes[_tr.pos];
	var _a = _tr.act;
	if (_phase == "all" || _phase == "open") {
		var _rmax = 0, _nstock = 1;
		switch (_nd.kind) { case "village": _rmax = 1; _nstock = irandom_range(1, 2); break; case "town": _rmax = 2; _nstock = 2; break; case "city": _rmax = 3; _nstock = 3; break; }
		// THE SIGN
		var _sign;
		var _sf = random(100);
		if (_sf < 40) _sign = "the " + choose("crooked", "bent", "dented", "rusty", "golden", "leaning", "quiet", "loud", "blue", "red", "old", "honest", "second", "little") + " " + choose("kettle", "nail", "spoon", "anvil", "boot", "hat", "goose", "pig", "lantern", "bucket", "bell", "crow", "wheel", "door");
		else if (_sf < 65) _sign = "the " + choose("three", "two", "seven", "nine", "twelve") + " " + choose("pigs", "spoons", "hats", "bells", "crows", "boots", "kettles", "geese");
		else if (_sf < 85) _sign = exped_npc_name() + "'s " + choose("ironmongery", "emporium", "stall", "shop", "goods", "odds and ends", "outfitters", "bits", "warehouse (small)");
		else _sign = choose("goods", "wares", "things", "sundries", "everything", "bits and pieces") + " " + choose("and more", "of quality", "for sale", "and such", "at prices");
		// THE PLACE'S OWN SHOP (the recurring folk, 2026-09-16): the papers name the keeper and the sign, the same on every visit
		var _ppk = region_node_info(_tr.dest, _rg, _tr.pos);
		var _keeper = is_struct(_ppk[$ "folk"]) ? _ppk.folk.keeper : exped_npc_name();
		if (is_struct(_ppk[$ "shop"])) _sign = _ppk.shop.sign;
		// THE STOCK, laid out once: every member sees the same shelf
		// THE SHELF REMEMBERED (the world remembers, 2026-09-16): as it was left last time, sold gaps and all, until the restock
		var _shm = exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "shelf");
		var _stock = [], _remembered = false;
		if (is_struct(_shm) && _shm.pay != "") {
			var _sit = string_split(_shm.pay, ";");
			for (var _s = 0; _s < array_length(_sit); _s++) { var _sf = string_split(_sit[_s], ":", false, 2); if (array_length(_sf) < 3) continue; var _sit2 = gear_unpack(_sf[2]); if (is_undefined(_sit2)) continue; array_push(_stock, { it : _sit2, price : max(1, real(_sf[0])), sold : (_sf[1] == "1") }); }
			_remembered = (array_length(_stock) > 0);
		}
		var _wl = _rg[$ "wild"] ?? [];
		if (!_remembered) for (var _s = 0; _s < _nstock; _s++) {
			var _rar = irandom(_rmax);
			// A POTION on the shelf (2026-09-16): a settlement's one thing more often than not; a big one where the rung allows
			if (random(1) < ((_nd.kind == "settlement") ? .6 : .3)) {
				var _pk = choose("hp", "hp", "hp", "mp", "tonic"), _psz = (_rar > 0 && random(1) < .5) ? 2 : 1;
				array_push(_stock, { it : use_gen(_pk, _psz, _rg.lv), price : 1 + _psz + ((_pk == "tonic") ? 1 : 0), sold : false });
				continue;
			}
			var _slot = choose("w1", "w2", "armor", "talis");
			var _tags = (array_length(_wl) > 0 && random(1) < .5) ? _wl[irandom(array_length(_wl) - 1)] : _nd.kind;
			array_push(_stock, { it : gear_gen(_slot, _rg.lv, _rar, irandom($7fffffff), _tags), price : 2 + floor(_rg.lv / 3) + 2 * _rar, sold : false });
		}
		var _shop = { sign : _sign, keeper : _keeper, stock : _stock, bought : 0, mem_left : (is_struct(_shm) && _remembered) ? _shm.left : 0 };
		if (is_struct(_a)) _a.shop = _shop; else { _a = { shop : _shop }; }
		array_push(_tr.log, "the shop in " + _nd.name + ": " + _sign + ". " + choose(_keeper + " keeps it", _keeper + " behind the counter", "a sprite called " + _keeper + " and a cat", _keeper + ", who does not look up", "kept by " + _keeper + ", who does") + (_remembered ? choose(". the shelf is as they left it", ". the same things on the shelf, less what went", ". nothing new on the shelf yet") : ""));
		if (_phase == "open") return;
	}
	var _shop2 = is_struct(_a) ? _a[$ "shop"] : undefined;
	if (!is_struct(_shop2)) return;
	var _stock2 = _shop2.stock, _keeper2 = _shop2.keeper, _sign2 = _shop2.sign;
	var _pl = sprite_personalities();
	var _k0 = (_phase == "buy") ? _k : 0, _k1 = (_phase == "buy") ? _k + 1 : array_length(_tr.sids);
	if (_phase != "close") for (var _k2 = max(0, _k0); _k2 < min(_k1, array_length(_tr.sids)); _k2++) {
		if (_tr.hp[_k2] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k2]);
		if (is_undefined(_sp)) continue;
		var _pn = _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name;
		var _hag = (_pn == "greedy" || _pn == "sly") ? -1 : ((_pn == "kind") ? 1 : 0);
		if (sprite_note_has(_sp, "shop")) _hag -= 1;   // (a note on shops: the haggle, 2026-09-16)
		if (is_struct(exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "grateful"))) _hag -= 1;   // (a grateful town: a credit off - the world remembers)
		// the best thing on the shelf for this one, by its own eye
		var _best = -1, _bgain = 0;
		for (var _s = 0; _s < array_length(_stock2); _s++) {
			if (_stock2[_s].sold) continue;
			var _it = _stock2[_s].it, _slot = _it.slot;
			if (_slot == "use") continue;   // (the potions: below, once the gear has been looked at)
			var _sh = sprite_sheet(_sp), _c = sprite_classes()[_sh.cls];
			var _cur = 0;
			if (_slot == "w1" || _slot == "w2") _cur = gear_score(_sp, _sh[$ _slot]);
			else {
				var _arr = _sh[$ _slot], _cap = (_slot == "armor") ? _c.armor : _c.talis;
				if (array_length(_arr) >= _cap) { _cur = infinity; for (var _i = 0; _i < array_length(_arr); _i++) _cur = min(_cur, gear_score(_sp, _arr[_i])); }
			}
			var _gain = gear_score(_sp, _it) - _cur;
			if (_gain > _bgain) { _bgain = _gain; _best = _s; }
		}
		// A POTION (2026-09-16): wanted when the pocket holds fewer than two of its kind, seven times in ten
		if (_best < 0) {
			var _shp = sprite_sheet(_sp);
			for (var _s = 0; _s < array_length(_stock2) && _best < 0; _s++) {
				if (_stock2[_s].sold || _stock2[_s].it.slot != "use") continue;
				var _have = 0;
				for (var _j = 0; _j < array_length(_shp.inv); _j++) if ((_shp.inv[_j][$ "slot"] ?? "") == "use" && _shp.inv[_j].kind == _stock2[_s].it.kind) _have++;
				if (_have < 2 && roll_perc(70)) { _best = _s; _bgain = 1; }
			}
		}
		if (_best < 0) { if (roll_perc(30)) array_push(_tr.log, _sp.name + " " + choose("looked the shelf over and left it as it was", "picked things up and put them down in a different order", "asked the price of everything and bought the silence", "found nothing better than what is already on", "haggled over a thing and then did not want it")); continue; }
		var _st = _stock2[_best], _it2 = _st.it, _price = max(1, _st.price + _hag);
		if (_tr.credits >= _price) {
			_tr.credits -= _price;
			_st.sold = true;
			_shop2.bought += 1;
			exped_stat("bought");
			var _tk = sprite_take(_sp, _it2);
			if (_tk[$ "dumb"] ?? false) exped_tally(_tr, "mist"); else exped_tally(_tr, "items");
			var _hagt = (_hag < 0) ? choose(" (talked down by one)", " (a credit off, somehow)", " (haggled)") : ((_hag > 0) ? choose(" (paid a little extra, for the shopkeeper's dog)", " (rounded up, on purpose)") : "");
			array_push(_tr.log, _sp.name + " bought " + _it2.name + " for " + string(_price) + " credits" + _hagt + (_tk.worn ? "" : (_tk.kept ? " - and pocketed it" : " - " + string_delete(_tk.txt, 1, string_pos(" and ", _tk.txt) + 4))));
			if (_tk.worn) { _tr.hpmax[_k2] = sprite_pawn(_sp).maxhp; _tr.hp[_k2] = min(_tr.hp[_k2], _tr.hpmax[_k2]); }
			exped_say(_tr, "bought", { sid : _sp.id, item : _it2.name }, .55);   // (the buyer speaks - 2026-09-15)
		} else if (roll_perc(45)) {
			array_push(_tr.log, _sp.name + " looked at " + _it2.name + " (" + string(_price) + " credits) and " + choose("walked out", "put it back", "decided against it", "could not afford it", "counted the pocket twice and left", "asked " + _keeper2 + " to hold it. " + _keeper2 + " will not", "said \"next time\" to it, and meant it", "left a fingerprint on it and nothing else"));
		}
	}
	if (_phase == "buy") return;
	// THE SELLING (his pick, 2026-09-16): the worst of each pocket's gear goes over the counter at half the shelf's price -
	// one to three things a member by the stance (never a potion); a note on shops is a credit more a thing
	var _stn = exped_stance(_tr);
	for (var _k3 = 0; _k3 < array_length(_tr.sids); _k3++) {
		if (_tr.hp[_k3] <= 0) continue;
		var _sp3 = exped_sprite(_tr.sids[_k3]);
		if (is_undefined(_sp3)) continue;
		var _sh3 = sprite_sheet(_sp3), _sold3 = [], _csold = 0;
		repeat (_stn.sell) {
			var _wi = -1, _ws = infinity;
			for (var _j = 0; _j < array_length(_sh3.inv); _j++) { var _it3 = _sh3.inv[_j]; if ((_it3[$ "slot"] ?? "") == "use") continue; var _gs = gear_score(_sp3, _it3); if (_gs < _ws) { _ws = _gs; _wi = _j; } }
			if (_wi < 0) break;
			var _it4 = _sh3.inv[_wi];
			array_delete(_sh3.inv, _wi, 1);
			var _pr4 = max(1, floor((2 + floor(_rg.lv / 3) + 2 * (_it4[$ "rar"] ?? 0)) * .5)) + (sprite_note_has(_sp3, "shop") ? 1 : 0);
			_tr.credits += _pr4; _csold += _pr4;
			array_push(_sold3, _it4.name + " (" + string(_pr4) + ")");
		}
		if (array_length(_sold3) > 0) {
			exped_stat("sold", array_length(_sold3)); exped_tally(_tr, "earned", _csold); save_mark_dirty();
			array_push(_tr.log, _sp3.name + " sold " + exped_crew_txt(_sold3) + " to " + _keeper2 + choose(". " + _keeper2 + " weighed it in one hand", ". half what it was worth, and both of them knew it", ". the coins were counted twice", ". it went under the counter at once", "", ". " + _keeper2 + " did not ask where it came from"));
		}
	}
	// ...AND THE CREDITS (his joke, 2026-09-16): somebody tries to sell the keeper money. the keeper gives them a look
	if (_tr.credits > 0 && roll_perc(30)) {
		var _cand = [];
		for (var _k4 = 0; _k4 < array_length(_tr.sids); _k4++) {
			if (_tr.hp[_k4] <= 0) continue;
			var _sp4 = exped_sprite(_tr.sids[_k4]);
			if (is_undefined(_sp4)) continue;
			array_push(_cand, _k4);
			if (_pl[clamp(_sp4.pers, 0, array_length(_pl) - 1)].name == "dreamy") { array_push(_cand, _k4); array_push(_cand, _k4); }   // (the dreamy, three times as likely)
		}
		if (array_length(_cand) > 0) {
			var _jn = _tr.names[_cand[irandom(array_length(_cand) - 1)]];
			exped_tally(_tr, "mist");
			array_push(_tr.log, choose(
				_jn + " tried to sell " + _keeper2 + " two credits. for three credits. " + _keeper2 + " gave " + _jn + " a look",
				_jn + " put a credit on the counter and asked what " + _keeper2 + " would give for it. " + _keeper2 + " looked at " + _jn + " for a long time, then at the cat",
				_jn + " offered " + _keeper2 + " the pocket's credits at a fair price. the look " + _keeper2 + " gave is still going",
				_jn + " tried to sell a credit. " + _keeper2 + " said it was already a credit. " + _jn + " asked for a better price",
				_jn + " held up a credit and said \"how much\". " + _keeper2 + " did not answer. the look answered"));
		}
	}
	// ...and the shelf remembered until the restock (the world remembers, 2026-09-16): two days from the first look
	var _spay = "";
	for (var _s = 0; _s < array_length(_stock2); _s++) _spay += ((_s > 0) ? ";" : "") + string(_stock2[_s].price) + ":" + (_stock2[_s].sold ? "1" : "0") + ":" + gear_pack(_stock2[_s].it);
	var _sleft = _shop2[$ "mem_left"] ?? 0;
	if (_spay != "") exped_mem_set(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "shelf", (_sleft > 0) ? (_sleft / EXPED_HOUR) : 48, _spay);
	if (_shop2.bought == 0 && roll_perc(50)) array_push(_tr.log, choose("the shops of " + _nd.name + " had nothing worth the walk", _sign2 + " had nothing for them, and " + _keeper2 + " said so", "nothing bought in " + _nd.name + ". " + _keeper2 + " watched them go", "the shelf was looked at. the shelf was left", "the shop's best thing was the cat, which was not for sale"));
	else if (_shop2.bought > 0 && roll_perc(30)) array_push(_tr.log, _keeper2 + " " + choose("wrapped it in paper that had been used before", "said it was the last one. it was not", "threw in a piece of string", "bit the coin, out of habit", "said \"come back\", in a voice that did not care either way"));
}
