/// @description ui_anim_in(a, [i]) - how far part _i has arrived, 0..1,
/// given the panel's master open ease _a.
///
/// ⚖️ THE PARTS DO NOT ARRIVE TOGETHER (his ask, 2026-09-09: settings
/// and statistics "just pop in"). A panel that fades in as one flat
/// sheet is barely better than a pop - the eye reads one event either
/// way. What makes an opening read as an opening is ORDER: the ground
/// lands, then the strip, then the list deals in behind it. So every
/// part asks this the same question with a different index, and the
/// index is the whole animation.
///
/// _i is a POSITION, not an identity: rows pass their index down the
/// visible list, so the top row always leads whatever you had scrolled
/// to. Past UI_IN_STEPS the delay stops growing - a hundred-row list
/// must not take a hundred steps to arrive, and past about seven the
/// cascade has already said what it has to say.
///
/// The curve is ease-OUT cubic: it leaves fast and arrives soft, which
/// is the shape of something being placed. Ease-in would read as the
/// panel being dropped.
function ui_anim_in(_a, _i = 0) {
	var _d = min(max(_i, 0), UI_IN_STEPS) * UI_IN_STAGGER;
	// the span left for one part once the last one's delay is spent -
	// so the whole cascade still finishes exactly when _a reaches 1
	var _p = clamp((_a - _d) / max(.05, 1 - UI_IN_STEPS * UI_IN_STAGGER), 0, 1);
	var _q = 1 - _p;
	return 1 - _q * _q * _q;
}
