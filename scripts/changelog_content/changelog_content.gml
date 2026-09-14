/// @description changelog_content() -> THE RELEASES, newest first - the
/// one file the in-game changelog reads (his ask, 2026-09-14: "DE did
/// something like this but it was a hassle to work with"). A release is
/// a struct:
///   ver    the version string as it prints ("1.0.0")
///   date   a date string, printed as it is
///   name   the release's title - what it was about
///   notes  the lines, in order, each { kind, txt }: kind is one of
///          "added" / "changed" / "fixed" / "balance" / "note" and picks
///          the tag chip's colour (changelog_kind_col); txt wraps
/// >>> TO ADD A RELEASE: push one struct at the FRONT of the array below.
/// >>> Nothing else changes - the panel builds itself from this list, and
/// >>> the "new" pip on the settings row compares the newest ver here
/// >>> against the one the player last opened (g.changelog_seen).
///
/// ⚖️ THREE RELEASES BELOW ARE SAMPLES (2026-09-14), written to feel the
/// panel out before the game ships; replace them with the real first
/// release's notes. Until release the file is not maintained.
function changelog_content() {
	static _r = [
		{ ver : "1.0.2", date : "2026-10-02", name : "the quiet one",
		  notes : [
			{ kind : "fixed",   txt : "loading a save from an older build no longer adopts the other profile's coin, cheat rows or ability deck" },
			{ kind : "fixed",   txt : "the visualiser drew the units of a lower field inside a completed square (the green corners)" },
			{ kind : "fixed",   txt : "a fullscreen window that came back from a display refresh at the boot size is re-asserted" },
			{ kind : "changed", txt : "the objective card stays open on every new objective until you tap it" },
			{ kind : "balance", txt : "the time bank: capacity 10 min +10 a level, fees 6+5n / 5+4n banked minutes, the rate ceiling 20" },
			{ kind : "balance", txt : "dial milestones past level 100: 250 speed x2, 500 profit x5, 1000 profit x10, 2000 speed x2, 5000 and 10000 profit x100" },
		  ] },
		{ ver : "1.0.1", date : "2026-09-25", name : "the settings pass",
		  notes : [
			{ kind : "added",   txt : "an interface tab in settings: the menu, the screen and the title backdrop live there now" },
			{ kind : "added",   txt : "hold a visualiser knob in the money room and the settings screen fades to the knob so you see the change live" },
			{ kind : "added",   txt : "the dial autobuy is one master row with a target (strongest / cheapest / lowest / robin) and a filter of dial chips" },
			{ kind : "changed", txt : "every timer track snaps to four price stops - 30, 20, 10 and 5 seconds for 1 to 4 sticks" },
			{ kind : "changed", txt : "the swappable sounds were normalised: every option plays at one loudness" },
			{ kind : "changed", txt : "the reset rows in settings are hold-to-execute" },
			{ kind : "fixed",   txt : "sliders no longer drag behind an open dropdown" },
			{ kind : "fixed",   txt : "the tap and dial volume faders auditioned on every frame of a drag" },
		  ] },
		{ ver : "1.0.0", date : "2026-09-18", name : "release",
		  notes : [
			{ kind : "note",    txt : "the first build on the store. everything below is what shipped." },
			{ kind : "added",   txt : "the money room, thirteen dials, the tap, the overcharger, critical taps" },
			{ kind : "added",   txt : "the upgrade table, the credit dropper and the credit core" },
			{ kind : "added",   txt : "the tile table with the fabricator, the automerger and the shard upgrades" },
			{ kind : "added",   txt : "rebirth, the milestone scale, the cheat shop and the ability deck" },
			{ kind : "added",   txt : "automation with RAM, overclock notches and modes; the battery for the time away; the time bank" },
			{ kind : "added",   txt : "expeditions with the sprites, the daily gift, the offline log, statistics with favourites" },
			{ kind : "added",   txt : "the objectives chain that teaches all of it, the dice, the coin and the puck" },
		  ] },
	];
	return _r;
}
