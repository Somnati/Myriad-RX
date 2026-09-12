"""sprites_twin.py - the sprites' work, simulated.

The claim the design makes: a sprite is worth the same whether you are
watching it or not. Three executors must agree on one rate,
sprite_rate = work x pace / SPRITE_TAP_T:
  - obj_blob's LIVE loop (work / idle / wander / nap) - a Monte Carlo
    of the state machine, term for term with the GML
  - sprites_tick, headless (accrues sprite_rate directly)
  - sprites_offline (T ln(1 + A/T) seconds of work at sprite_rate)
This twin runs the state machine and checks its time-in-work fraction
against the personality's `work`. If they disagree, the live sprite
earns more (or less) than the headless one, and watching it would
change what it makes.

Reads SPRITE_* from main_macros.gml and the personalities' work/pace
from sprite_personalities.gml, so it cannot drift from the game.

Run:  python datafiles/sprites_twin.py
"""

import math
import os
import random
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_mac = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
_per = open(os.path.join(ROOT, "scripts", "sprite_personalities", "sprite_personalities.gml"), encoding="utf-8").read()
_blob = open(os.path.join(ROOT, "objects", "obj_blob", "Create_0.gml"), encoding="utf-8").read()


def macro(name):
    m = re.search(r"^#macro\s+" + name + r"\s+([-\d.]+)", _mac, re.M)
    if not m:
        raise SystemExit("main_macros has no #macro " + name)
    return float(m.group(1))


SPRITE_TAP_T    = macro("SPRITE_TAP_T")
SPRITE_ATTN     = macro("SPRITE_ATTN")
SPRITE_RAR_PACE = macro("SPRITE_RAR_PACE")   # pace x (1 + this x rarity rung)
_step = open(os.path.join(ROOT, "objects", "obj_blob", "Step_0.gml"), encoding="utf-8").read()

PERS = [(m.group(1), float(m.group(2)), float(m.group(3)))
        for m in re.finditer(r'name\s*:\s*"(\w+)",\s*work\s*:\s*([\d.]+),\s*pace\s*:\s*([\d.]+)', _per)]
if not PERS:
    raise SystemExit("could not read the personalities")

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label + (("   " + detail) if detail else ""))


# ---------------------------------------------------------------- the live loop, term for term
# obj_blob's __next_state: the state durations, read from the GML so a
# retune there is a retune here
def _rng(name):
    m = re.search(name + r"[^\n]*?random_range\(([\d.]+),\s*([\d.]+)\)", _blob, re.M)
    return (float(m.group(1)), float(m.group(2))) if m else None


DUR_SLOT = _rng(r"^\s*st_t = ")             # the shared slot (every state the same length)
DUR_WORK = _rng(r"st = 2;") or DUR_SLOT or (240, 480)
DUR_IDLE = _rng(r"st = 0;") or DUR_SLOT or (90, 200)
if DUR_SLOT is None:
    raise SystemExit("obj_blob's __next_state no longer sets a shared st_t slot - update the twin")
WALK_SPD = .35


def live_fraction(work, pace, frames=60 * 3600 * 20, seed=1):
    """Monte Carlo of obj_blob: how much of its time it spends in WORK."""
    rnd = random.Random(seed)
    t = 0
    in_work = 0
    x, y = 240.0, 200.0
    while t < frames:
        if rnd.random() < work:
            d = rnd.uniform(*DUR_WORK); in_work += d; t += d
        elif rnd.random() < .5:
            d = rnd.uniform(*DUR_IDLE); t += d
        else:
            # wander: walk to a random target in the lower third, then the
            # slot ends on arrival (or the slot's cap)
            tx, ty = rnd.uniform(14, 466), rnd.uniform(162, 242)
            dist = math.hypot(tx - x, ty - y)
            walk = dist / (WALK_SPD * pace)
            cap = DUR_SLOT[1] if DUR_SLOT else 600
            if DUR_SLOT:
                # the loop's wander slot: walk, then stand until the slot ends
                d = rnd.uniform(*DUR_SLOT)
            else:
                d = min(walk, cap)
            x, y = tx, ty
            t += d
    return in_work / t


# ⚖️ THE CADENCE, not just the fraction (2026-09-12). sprite_rate is
# work x pace x (1 + RAR_PACE x rar) / TAP_T; the live loop taps every
# TAP_T x 60 frames at `delta x pace x ...`. The Monte Carlo below checks
# the WORK fraction; this checks the pace term is the same product in
# both places by reading the live loop's line. It was not - the rarity
# factor was in sprite_rate and missing from obj_blob, so an ultimate
# tapped x1.84 faster off screen than on it. Exactly the drift this
# file exists to catch, and it could not see it.
_m = re.search(r"^\s*tap_t\s*-=\s*(.+?);", _step, re.M)
_cad = _m.group(1) if _m else ""
print("\n== 0. the live cadence is sprite_rate's pace term ==")
print("  obj_blob: tap_t -= " + _cad)
say(bool(_m) and "_p.pace" in _cad and "SPRITE_RAR_PACE" in _cad and "rar" in _cad,
    "the live loop's cadence carries personality pace AND the rarity pace, as sprite_rate does")

print("\n== 1. watching it vs not: the live loop's time in WORK against the personality ==")
print(f"  durations read from obj_blob: work {DUR_WORK}, idle {DUR_IDLE}, slot {DUR_SLOT}")
worst = 0
for name, work, pace in PERS:
    f = live_fraction(work, pace)
    err = abs(f - work) / work
    worst = max(worst, err)
    flag = "" if err < .06 else "   <-- off by {:.0f}%".format(err * 100)
    print(f"  {name:<9} work {work:.2f}  live {f:.2f}  (taps/s {work * pace / SPRITE_TAP_T:.3f} claimed, {f * pace / SPRITE_TAP_T:.3f} live){flag}")
say(worst < .06, "the live loop's work fraction matches every personality within 6%",
    f"worst {worst * 100:.0f}%")

# ---------------------------------------------------------------- the offline law
print("\n== 2. the offline law (attention decay) ==")


def offline_work(away_s):
    return SPRITE_ATTN * math.log(1 + away_s / SPRITE_ATTN)


for h in (.5, 1, 3, 8, 24, 168):
    w = offline_work(h * 3600)
    print(f"  {h:>5}h away -> {w / 3600:5.2f}h of work  ({w / (h * 3600) * 100:5.1f}% of live)")
say(offline_work(600) > 600 * .9, "ten minutes away is nearly full work", f"{offline_work(600) / 600 * 100:.0f}%")
say(offline_work(8 * 3600) < 8 * 3600 * .5, "a night away is well under half", f"{offline_work(8 * 3600) / 3600:.1f}h")
say(offline_work(7 * 86400) < offline_work(86400) * 3, "a week is less than three days' worth - it keeps diminishing")
# the sprites are FREE: per sprite per day, at the strongest personality
# (a common; rarity multiplies the pace by 1 + RAR_PACE x rung, so an
# ultimate at rung 7 is x{:.2f} of this)
best = max(PERS, key=lambda p: p[1] * p[2])
rate = best[1] * best[2] / SPRITE_TAP_T
print("  rarity: x%.2f an ultimate (rung 7) against a common" % (1 + SPRITE_RAR_PACE * 7))
print(f"  the strongest ({best[0]}, common): {rate:.3f} taps/s live = {rate * 3600:.0f} an hour; "
      f"a night away yields {rate * offline_work(8 * 3600):.0f} taps")

print("\n" + ("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port"))
