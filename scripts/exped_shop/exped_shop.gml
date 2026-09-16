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
/// on the activity (act.shop); "buy" is ONE member's look (k); "close" the last
/// word; "all" the whole visit in one (the old way, for any other caller).
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
		var _keeper = exped_npc_name();
		// THE STOCK, laid out once: every member sees the same shelf
		var _stock = [];
		var _wl = _rg[$ "wild"] ?? [];
		for (var _s = 0; _s < _nstock; _s++) {
			var _slot = choose("w1", "w2", "armor", "talis");
			var _rar = irandom(_rmax);
			var _tags = (array_length(_wl) > 0 && random(1) < .5) ? _wl[irandom(array_length(_wl) - 1)] : _nd.kind;
			array_push(_stock, { it : gear_gen(_slot, _rg.lv, _rar, irandom($7fffffff), _tags), price : 2 + floor(_rg.lv / 3) + 2 * _rar, sold : false });
		}
		var _shop = { sign : _sign, keeper : _keeper, stock : _stock, bought : 0 };
		if (is_struct(_a)) _a.shop = _shop; else { _a = { shop : _shop }; }
		array_push(_tr.log, "the shop in " + _nd.name + ": " + _sign + ". " + choose(_keeper + " keeps it", _keeper + " behind the counter", "a sprite called " + _keeper + " and a cat", _keeper + ", who does not look up", "kept by " + _keeper + ", who does"));
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
		// the best thing on the shelf for this one, by its own eye
		var _best = -1, _bgain = 0;
		for (var _s = 0; _s < array_length(_stock2); _s++) {
			if (_stock2[_s].sold) continue;
			var _it = _stock2[_s].it, _slot = _it.slot;
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
	if (_shop2.bought == 0 && roll_perc(50)) array_push(_tr.log, choose("the shops of " + _nd.name + " had nothing worth the walk", _sign2 + " had nothing for them, and " + _keeper2 + " said so", "nothing bought in " + _nd.name + ". " + _keeper2 + " watched them go", "the shelf was looked at. the shelf was left", "the shop's best thing was the cat, which was not for sale"));
	else if (_shop2.bought > 0 && roll_perc(30)) array_push(_tr.log, _keeper2 + " " + choose("wrapped it in paper that had been used before", "said it was the last one. it was not", "threw in a piece of string", "bit the coin, out of habit", "said \"come back\", in a voice that did not care either way"));
}
