/// @description mood_base(sprite) -> { v, a } the sprite's RESTING mood by personality - where the drives drift back to (q261)
/// A cheerful sprite rests a little happy, a grumpy one a little sad, a
/// nervous one keyed-up, a sleepy one calm. The word derives from the
/// distance off this, so a grumpy sprite at its rest has no word - it is
/// just grumpy, which the personality already says
function mood_base(_sp) {
	static _t = {
		eager : [ .10, .60 ], sleepy : [ .00, .10 ], smug : [ .10, .40 ], curious : [ .10, .50 ], grumpy : [ -.20, .30 ],
		cheerful : [ .30, .50 ], shy : [ -.05, .20 ], greedy : [ .00, .40 ], brave : [ .10, .60 ], dreamy : [ .10, .15 ],
		nervous : [ -.10, .70 ], proud : [ .10, .45 ], kind : [ .15, .30 ], sly : [ .00, .35 ],
	};
	var _pl = sprite_personalities();
	var _pn = _pl[clamp(_sp[$ "pers"] ?? 0, 0, array_length(_pl) - 1)].name;
	var _b = _t[$ _pn];
	if (!is_array(_b)) return { v : 0, a : .4 };
	return { v : _b[0], a : _b[1] };
}
