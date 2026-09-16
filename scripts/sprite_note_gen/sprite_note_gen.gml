/// @description sprite_note_gen(sprite, beat, [ctx]) -> a note's text ("" = nothing came to mind)
/// What a sprite would write, by beat:
///   "foe"    after a fight, about ctx.foe (a pawn): a true thing read off
///            its shape - quick / armoured / a tank / a caster / armed /
///            a boss - in its own dim words; tagged foe:<kind> by the
///            caller so it counts (SPRITE_NOTE_HIT)
///   "rout"   after a rout, about ctx.foe: a resolution
///   "land" / "rest" / "find" / "home" / "levelup" / "road"   the useless kind
/// ctx: { foe, item, planet, partner, lv }. The chance to write at all
/// is the caller's; this only decides what.
function sprite_note_gen(_sp, _beat, _ctx = undefined) {
	if (!is_struct(_ctx)) _ctx = {};
	var _foe  = _ctx[$ "foe"];
	var _kind = is_struct(_foe) ? (_foe[$ "kind"] ?? "it") : "it";
	var _ks   = foe_plural(_kind);
	switch (_beat) {
		case "foe": {
			if (!is_struct(_foe)) return "";
			var _opts = [];
			if (_foe[$ "boss"] ?? false) array_push(_opts, "the " + _foe.name + " exists. avoid.", "met the " + _foe.name + ". it has a title. we do not.");
			if (array_length(_foe[$ "worn"] ?? []) > 0) array_push(_opts, "one of the " + _ks + " had a " + _foe.worn[0].name + ". rude.", _ks + " carry things. they are not for sharing.");
			if (_foe.spd >= 6.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " are quick. swing early.", _ks + " move before you have decided to.");
			if (_foe.def >= 5.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " wear things. aim for the gaps.", "hitting a " + _kind + " is like hitting a door.");
			if (_foe.maxhp_real >= 30 * (_foe.pts_total / 40)) array_push(_opts, _ks + " take ages. bring snacks.", "a " + _kind + " does not go down. it goes sideways, slowly.");
			if (_foe[$ "magic"] ?? false) array_push(_opts, _ks + " do the glowy thing. do not stand in it.", "a " + _kind + " hums before it hurts. the hum is the warning.");
			if (_foe.atk >= 6.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " hit hard. do not be where the hit is.", "a " + _kind + " swings like it means it.");
			if (_foe.hit <= 4.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " miss a lot. stand still and look confident.");
			array_push(_opts, _kind + ": hits back. noted.", "a " + _kind + " is a " + _kind + ". writing it down anyway.",
			           _ks + " smell like " + _ks + ". you will know.", "met a " + _kind + ". it did not want to be met.", _ks + ": count them first. then count again. then leave.",
			           "a " + _kind + " has a front and a back. the back is better.", _ks + " are not friendly. checked.");
			return _opts[irandom(array_length(_opts) - 1)];
		}
		case "rout":
			return choose(_ks + ": no. just no.", "do not go near " + _ks + " again. underline this.", _ks + ". the bad kind.", "lost to a " + _kind + ". the notepad was not helpful.",
			              "ran from " + _ks + ". running is a skill. i have it.", _ks + ": more of them than us. maths.", "note: " + _ks + " do not accept apologies.",
			              "the " + _kind + " is still there. i am not. good.", "lesson from the " + _ks + ": legs first, then thinking.", _ks + ". never again. until the next time.");
		case "land":
			return choose((_ctx[$ "planet"] ?? "this place") + " has a smell.", "the sky here is a colour.", "the ground is mostly down.",
			              "the third rock from the left is nice.", "if lost, keep going.", "landed. wrote that down so it counts.",
			              "gravity here is normal. checked twice.", "there is a hill. it is not important.",
			              "the air tastes of outside.", "landed on " + (_ctx[$ "planet"] ?? "a place") + ". it was here when we arrived. suspicious.", "the horizon is further than it looks. it always is.",
			              "step one: get off the ship. done.", "rocks: yes. trees: some. me: here.", "remember which way the ship is. (this way.) (or that way.)",
			              "a bird looked at me. i looked back. draw.", "the landing zone is a zone. nobody said what kind.", "new place. same feet.");
		case "rest":
			return choose("inn beds face north. or south.", "rested. dreamt of a spoon.", "note to self: i am " + _sp.name + ".",
			              "remember to buy eggs.", "left foot first when stepping over roots.", "the last room was a room.",
			              "i think the moon is following us.", "don't trust ladders.", "ask " + (_ctx[$ "partner"] ?? "someone") + " about the thing.",
			              "slept. woke up. both went well.", "the pillow was a bag. the bag was a pillow. no notes.", "dreamt of home. home was smaller.",
			              "a good sit. rating: sit.", "the fire made a noise like a word. the word was probably \"fire\".", "resting is just walking with the legs off.",
			              "counted my fingers. all present. one was thumb.", "tomorrow: more of today, probably.", "the ceiling here is very high. it is the sky.");
		case "find":
			return choose("the " + (_ctx[$ "item"] ?? "thing") + " is heavier than it looks.", "found a good stick. lost it.",
			              "the " + (_ctx[$ "item"] ?? "thing") + ". keep? probably.", "things are on the ground here. free.",
			              "goblins count as three geese.", "picked something up. it was there.",
			              "the " + (_ctx[$ "item"] ?? "thing") + " smells of the place it was in.", "found it. nobody else did. that makes it mine, i think.",
			              "one " + (_ctx[$ "item"] ?? "thing") + ". do not lose. (again.)", "finding things is easy. it is the looking that is hard.",
			              "the " + (_ctx[$ "item"] ?? "thing") + " may be cursed. keeping it anyway.", "everything is treasure if you lift it.");
		case "home":
			return choose("home. the notepad survived. barely.", "back. nothing has changed. good.", "to do: nothing. done.",
			              "the ship still smells of last time.", "arrived where we left from. the maths works.",
			              "home. the floor is where i left it.", "back. told the story. it got bigger on the way.", "note: the ship door sticks. it stuck.",
			              "home is the place where the bag goes down.", "counted the crew. all here. counted again to be sure. all here, twice.", "unpacked. repacked. life.");
		case "road":
			return choose("the road is long. so are my legs, for some reason.", "counted 40 trees. gave up. 41.",
			              "there was a rock that looked like " + (_ctx[$ "partner"] ?? "someone") + ".", "a bird followed us for an hour. it knows something.",
			              "walking is just falling with confidence.", (_ctx[$ "partner"] ?? "someone") + " hums. it is always the same tune. i will find the tune.",
			              "left, right, left. there is a pattern here.", "the sky is bigger out here. suspicious.", "my boots have opinions.",
			              "a puddle. went round it. it was longer than it looked.", "milestone said 4. four what. four.", "the road went up. i went up. we are both up now.",
			              "passed a cow. the cow passed me, in a sense.", "if the road bends, bend with it. if it stops, sit.", "one hour of road = one hour of thinking about lunch.",
			              "the wind is from the left today. write that down. (done.)", "a signpost pointed at a field. the field had no comment.");
		case "levelup":
			return choose("level " + string(_ctx[$ "lv"] ?? 2) + ". felt nothing.", "stronger now. same hat.",
			              "level " + string(_ctx[$ "lv"] ?? 2) + ". wrote it bigger than the others.", "got better at it. at what, unclear.",
			              "level " + string(_ctx[$ "lv"] ?? 2) + ". the number went up. i went up with it, i think.", "a level. checked for new muscles. inconclusive.",
			              "stronger. the bag disagrees.", "level " + string(_ctx[$ "lv"] ?? 2) + ". telling everyone. told the diary first. it is the diary.");
	}
	return "";
}
