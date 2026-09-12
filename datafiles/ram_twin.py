"""ram_twin.py - the automation budget, simulated.

The house pattern: model the shipped maths in Python, state the
invariants out loud, print HOLDS or FAILS. Tune here, port the numbers
back - never the other way round.

THE NUMBERS ARE READ FROM main_macros.gml (RAM_*) and the price list is
ram_cost's, term for term, so this twin cannot drift from the game. The
laws: ram_cost / ram_used / ram_cap / ram_throttle, and what the
throttle does to every clock (autom_tick's timers, autom_rate's speeds,
fleet_total's rate).

Run:  python datafiles/ram_twin.py
"""

import math
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"),
            encoding="utf-8").read()


def macro(name):
    m = re.search(r"^#macro\s+" + name + r"\s+([-\d.]+)", _src, re.M)
    if not m:
        raise SystemExit("main_macros has no #macro " + name)
    return float(m.group(1))


RAM_BASE      = macro("RAM_BASE")
RAM_REB       = macro("RAM_REB")
RAM_REBIRTH   = macro("RAM_REBIRTH")
RAM_TIMER_MIN = macro("RAM_TIMER_MIN")
RAM_TIMER_MAX = macro("RAM_TIMER_MAX")
RAM_OC_N      = int(macro("RAM_OC_N"))
OC_MULT = [1.2, 1.5, 2]     # ram_oc's ladder: the notch's multiple of the track's end...
OC_COST = [1.6, 2.2, 3]     # ...and of the track's end PRICE (ceil'd)

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label
          + (("   " + detail) if detail else ""))


# ---------------------------------------------------------------- laws
def oc_k(kind, v):
    """ram_oc_k: the notch a value sits on, -1 if not overclocked"""
    if kind == "speed":
        if v <= 100: return -1
        m = v / 100.0
    elif kind == "tap":
        if v <= 10: return -1
        m = v / 10.0
    else:
        if v >= RAM_TIMER_MIN or v <= 0: return -1
        m = RAM_TIMER_MIN / v
    return min(range(RAM_OC_N), key=lambda k: abs(OC_MULT[k] - m))


def cost_timer(t):
    """ram_cost('timer', t)"""
    k = oc_k("timer", t)
    if k >= 0: return math.ceil(4 * OC_COST[k])
    if t <= 1: return 4
    if t <= 2: return 3
    if t <= 5: return 2
    return 1


def cost_speed(pct):
    """ram_cost('speed', pct): a stick per 20% (the sliders snap to 20/40/60/80/100)"""
    k = oc_k("speed", pct)
    if k >= 0: return math.ceil(5 * OC_COST[k])
    return max(1, math.ceil(pct / 20.0))


def cost_tap(tps):
    """ram_cost('tap', tps): a stick per 2 taps/s (the slider snaps to 2..10 by 2)"""
    k = oc_k("tap", tps)
    if k >= 0: return math.ceil(5 * OC_COST[k])
    return max(1, math.ceil(tps / 2.0))


def cap(rebirths=0):
    return RAM_BASE + rebirths * RAM_REB


def used(run=100, fab=100, merge=None, autobuys=(), roll=False, sell=False,
         buy_t=None, tile_buys=(), rebirth=False):
    """ram_used. run/fab/merge: a speed % or None for off; autobuys /
    tile_buys: timers in seconds; buy_t: the upgrade table's buy timer."""
    u = 0
    if run   is not None: u += cost_speed(run)
    if fab   is not None: u += cost_speed(fab)
    if merge is not None: u += cost_speed(merge)
    u += sum(cost_timer(t) for t in autobuys)
    u += (1 if roll else 0) + (1 if sell else 0)
    if buy_t is not None: u += cost_timer(buy_t)
    u += sum(cost_timer(t) for t in tile_buys)
    if rebirth: u += RAM_REBIRTH
    return u


def throttle(u, c):
    """ram_throttle: 1 inside the budget, cap/used over it, never 0"""
    if u <= 0: return 1.0
    return 1.0 if u <= c else c / u


# ---------------------------------------------------------------- 1. the defaults fit
print("\n== 1. the shipped setup ==")
u0 = used()
print(f"  base capacity {cap():.0f} sticks; the defaults (cycling 100%, fabricator 100%) use {u0}")
say(u0 <= cap(), "the defaults fit inside the base budget", f"{cap() - u0:.0f} sticks free")
free = cap() - u0
print(f"  what {free:.0f} free sticks buy: {free:.0f} autobuys at 30s, or "
      f"{free // 4:.0f} at 1s + {free % 4:.0f} slow, or the autorebirth ({RAM_REBIRTH:.0f}) + {free - RAM_REBIRTH:.0f} slow")
say(free >= 4, "a first-hour player can run the profit-boost autobuy fast OR several slow ones")

# ---------------------------------------------------------------- 2. the throttle
print("\n== 2. over the budget ==")
u = used(autobuys=[1, 1, 1])          # three dials at 1s
th = throttle(u, cap())
say(0 < th < 1, "three 1s dial autobuys over the base budget throttle, never stop",
    f"used {u} of {cap():.0f} -> x{th:.2f} on every clock")
print("  what x{:.2f} means: production (the dials' cycling) at {:.0f}%, every timer {:.2f}x longer,"
      " the fabricator and merger at {:.0f}%".format(th, th * 100, 1 / th, th * 100))
# the trade: attempts per minute of an autobuy at timer t under throttle th
def attempts_per_min(t, th): return 60.0 * th / t
configs = {
    "one dial at 1s (fits)":            dict(autobuys=[1]),
    "three dials at 1s (over)":         dict(autobuys=[1, 1, 1]),
    "three dials at 5s (fits)":         dict(autobuys=[5, 5, 5]),
    "six dials at 30s (fits)":          dict(autobuys=[30] * 6),
    "six dials at 5s (over)":           dict(autobuys=[5] * 6),
}
print(f"  {'setup':<28} {'used':>4} {'throttle':>8} {'autobuy attempts/min':>22} {'production':>10}")
for name, kw in configs.items():
    uu = used(**kw)
    tt = throttle(uu, cap())
    apm = sum(attempts_per_min(t, tt) for t in kw["autobuys"])
    print(f"  {name:<28} {uu:>4} {tt:>8.2f} {apm:>22.1f} {tt * 100:>9.0f}%")
say(throttle(used(autobuys=[5] * 6), cap()) < 1,
    "six dials at 5s does NOT fit the base budget - a real choice between speed and breadth")

# ---------------------------------------------------------------- 3. the price list
print("\n== 3. the price list ==")
print("  timer:", "  ".join(f"{t}s={cost_timer(t)}" for t in (1, 2, 3, 5, 6, 10, 30)))
print("  speed:", "  ".join(f"{p}%={cost_speed(p)}" for p in (5, 20, 21, 40, 60, 80, 100)))
say(cost_timer(RAM_TIMER_MAX) == 1 and cost_timer(RAM_TIMER_MIN) == 4,
    "the slowest timer is 1 stick, the fastest 4")
say(cost_speed(100) == 5 and cost_speed(5) == 1, "a machine is 5 sticks flat out, 1 at a crawl")
print("  the cheap way to run a machine: 20% costs 1 stick for a fifth of the speed -"
      " the same output per stick as 100% for 5; RAM is linear in speed, so speed sliders"
      " only matter when the budget pinches (unlike the battery, where slower is cheaper per output)")

# ---------------------------------------------------------------- 4. rebirths grow the budget
print("\n== 4. rebirths ==")
for r in (0, 1, 3, 5, 10, 20):
    c = cap(r)
    print(f"  {r:>2} rebirths: {c:.0f} sticks - the defaults + {c - u0:.0f} free")
say(cap(5) - u0 >= 3 * 4, "five rebirths in, three dials can run at 1s alongside the defaults")
say(cap(20) - u0 >= 13, "twenty rebirths in, every dial can autobuy at once (slowly)")

# ---------------------------------------------------------------- 5. the full-table player
print("\n== 5. the everything-on player ==")
u_all = used(merge=100, autobuys=[30] * 13, roll=True, sell=True, buy_t=30,
             tile_buys=[30] * 7, rebirth=True)
print(f"  all three machines at 100%, thirteen dials + the table + seven tile rows at 30s,"
      f" roll, sell, the autorebirth: {u_all} sticks")
need = math.ceil((u_all - RAM_BASE) / RAM_REB)
print(f"  that fits the budget after {need} rebirths; before that it runs at"
      f" x{throttle(u_all, cap()):.2f} on a fresh save")
say(throttle(u_all, cap()) >= .3, "even everything-on from a fresh save keeps a third of full speed",
    f"x{throttle(u_all, cap()):.2f}")

# ---------------------------------------------------------------- 6. overclock
print("\n== 6. overclock (the three red notches) ==")
print("  speed notches:", "  ".join(f"{round(100 * OC_MULT[k])}%={cost_speed(round(100 * OC_MULT[k]))}" for k in range(RAM_OC_N)))
print("  tap notches:  ", "  ".join(f"{round(10 * OC_MULT[k])}/s={cost_tap(round(10 * OC_MULT[k]))}" for k in range(RAM_OC_N)))
print("  timer notches:", "  ".join(f"{RAM_TIMER_MIN / OC_MULT[k]:.2f}s={cost_timer(RAM_TIMER_MIN / OC_MULT[k])}" for k in range(RAM_OC_N)))
# the law: the price climbs faster than the gain, notch by notch
per_gain = [cost_speed(round(100 * OC_MULT[k])) / OC_MULT[k] for k in range(RAM_OC_N)]
say(all(per_gain[k] > per_gain[k - 1] for k in range(1, RAM_OC_N)) and per_gain[0] > cost_speed(100),
    "every notch costs more per unit of speed than the one before (and than 100%)",
    "sticks per x: " + ", ".join(f"{p:.1f}" for p in per_gain))
# a fresh save: the defaults (cycling + fabricator at 100%) leave 6 free
u_oc1 = used(run=120)
u_oc2 = used(run=150)
u_oc3 = used(run=200)
say(u_oc1 <= cap() and u_oc2 <= cap(), "a fresh save can overclock its cycling to 150% inside the budget",
    f"120%: {u_oc1}, 150%: {u_oc2} of {cap():.0f}")
say(u_oc3 > cap(), "200% cycling is out of a fresh save's reach - the x2 notch is a rebirth prize",
    f"200%: {u_oc3} of {cap():.0f}; fits after {math.ceil((u_oc3 - RAM_BASE) / RAM_REB)} rebirths")
# overclocking past the cap defeats itself: the throttle slows EVERYTHING,
# so what the notch gains the other machine loses - the sum of the two
# defaults' speeds is lower over budget at 200% than inside it at 150%
th3 = throttle(u_oc3, cap())
say(2 * th3 + th3 < 1.5 + 1, "200% over a fresh budget does less total work than 150% inside it",
    f"200%: cycling {200 * th3:.0f}% + fabricator {100 * th3:.0f}% vs 150% + 100%")
# an overclocked timer: 0.5s at 12 sticks vs two dials at 1s for 8
say(cost_timer(0.5) > 2 * cost_timer(1), "one 0.5s autobuy costs more than two at 1s - breadth beats depth by default",
    f"0.5s: {cost_timer(0.5)}, 2 x 1s: {2 * cost_timer(1)}")

print("\n" + ("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port"))
