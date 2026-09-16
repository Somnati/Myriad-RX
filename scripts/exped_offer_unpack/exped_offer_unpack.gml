/// @description exped_offer_unpack(s) - the offers rebuilt from exped_offer_pack's string (the quests regenerate from their salts on the first look)
function exped_offer_unpack(_s) {
	exped_init();
	g.exped.offers = {};
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "#");
	for (var _r = 0; _r < array_length(_recs); _r++) {
		var _p = string_split(_recs[_r], "|");
		if (array_length(_p) < 2) continue;
		var _hd = string_split(_p[0], ":");
		if (array_length(_hd) < 3) continue;
		var _of = { seed : real(_hd[0]), ri : clamp(real(_hd[1]), 0, EXPED_REGIONS - 1), next : max(0, real(_hd[2])), slots : [], d : undefined };
		for (var _i = 1; _i < array_length(_p); _i++) {
			var _f = string_split(_p[_i], "~");
			if (array_length(_f) < 4) continue;
			if (_f[0] == "P") {
				// THE PERSONAL CARD (2026-09-16): its raw fields; exped_offer_fill finishes it once the world is known
				var _qf = string_split(_f[3], "^");
				if (array_length(_qf) < 9 || _qf[0] == "") continue;
				var _nds = [];
				if (_qf[7] != "") { var _nl = string_split(_qf[7], ";"); for (var _j = 0; _j < array_length(_nl); _j++) if (_nl[_j] != "") array_push(_nds, real(_nl[_j])); }
				if (!is_array(_of[$ "pq"])) _of.pq = [];
				array_push(_of.pq, { q : undefined, raw : { kind : _qf[0], node : real(_qf[1]), from : real(_qf[2]), foe : foe_legacy(_qf[3]), n : max(1, real(_qf[4])), mult : real(_qf[5]), who : _qf[6], nodes : _nds, pnote : _qf[8], vil : (array_length(_qf) > 9) ? real(_qf[9]) : 0 },
				                     salt : -1, left : max(1, real(_f[1])), taken : real(_f[2]), easy : false, pers : true });
				continue;
			}
			if (array_length(_of.slots) >= EXPED_QUESTS) continue;
			array_push(_of.slots, { salt : real(_f[0]), left : max(1, real(_f[1])), taken : real(_f[2]), easy : (_f[3] == "1"), q : undefined });
		}
		if (array_length(_of.slots) != EXPED_QUESTS) continue;   // (a record from another count: it re-deals)
		g.exped.offers[$ string(_of.seed) + ":" + string(_of.ri)] = _of;
	}
}
