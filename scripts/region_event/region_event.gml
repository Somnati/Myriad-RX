/// @description region_event(dest, ri) -> { kind, node, left, txt } the region's event now, or undefined (a lull, or nothing yet)
/// REGION EVENTS (his pick, 2026-09-16), one at a time on the memory
/// clock (exped_event_tick rolls them; the memory "event" at node -1,
/// pay "kind:node" or "lull:-1"):
///   fair    at a town: the shelf twice itself and a rung up, beds half price, the tavern always
///   rats    a plague of rats in a town: rats in every fight the region rolls, three times over
///   lord    the villain abroad: camps a bandit stronger, bounties pay half again, passers-by turn out bandits
///   frost   a hard frost: the cold on the open lands, the rain is snow
function region_event(_d, _ri) {
	var _m = exped_mem_get(_d, _ri, -1, "event");
	if (!is_struct(_m)) return undefined;
	var _f = string_split(_m.pay, ":");
	if (array_length(_f) < 2 || _f[0] == "lull") return undefined;
	var _rg = region_get(_d, _ri);
	var _nd = clamp(real(_f[1]), -1, array_length(_rg.nodes) - 1);
	var _txt = "", _why = "";   // (why: the consequence, for the header - q285)
	switch (_f[0]) {
		case "fair":  _txt = "a fair at " + ((_nd >= 0) ? _rg.nodes[_nd].name : "the green"); _why = "stalls on the green - the shelf twice itself, a rung up"; break;
		case "rats":  _txt = "a plague of rats" + ((_nd >= 0) ? (" in " + _rg.nodes[_nd].name) : ""); _why = "rats in every fight, the folk indoors, the shelf thin"; break;
		case "lord":  { var _v = region_villain(_d, _rg); _txt = (is_struct(_v) ? _v.name : "a bandit lord") + " abroad"; _why = "his people on every road, one more at every camp"; break; }
		case "frost": _txt = "a hard frost"; _why = "the roads slow, the wild kinds hungry"; break;
		case "raid":  {   // THE RAID (q285): the villain fell on a settled place - its people fewer, its shelf thin, the roads his
			var _vr = region_villain(_d, _rg), _vs = g.exped[$ "seat"], _vsk = is_struct(_vs) ? _vs[$ lane_key(_d, _ri)] : undefined;
			var _vn = is_struct(_vr) ? _vr.name : ((is_struct(_vsk) && _vsk.left > 0) ? "the late lord's people" : "a bandit lord");
			_txt = _vn + " attacked " + ((_nd >= 0) ? _rg.nodes[_nd].name : "the roads"); _why = "fewer people there, the shelf thin, his people on the roads"; break;
		}
		default: return undefined;
	}
	return { kind : _f[0], node : _nd, left : _m.left, txt : _txt, why : _why };
}
