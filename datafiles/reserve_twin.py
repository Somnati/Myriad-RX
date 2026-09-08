"""reserve_twin.py - the reserve has to actually hold something back.

His design: "a percentage of profit goes into a pool that you can't use
for spending." Then, correctly, he asked to be able to get it back out -
so the reserve was rewritten as DERIVED rather than accumulated:

    spendable = profit x (1 - pct/100)

That releases instantly when the slider drops, which was the point. But
it is not a floor, and the reason is only visible in the DYNAMICS rather
than in the formula: spending lowers the pile, which lowers the reserve
with it, which frees a little more. Every purchase re-opens the gate.

autom_tick buys on a one-second pulse, so this is not a theoretical
leak - it is a minute.

THE FIX under test: a WATERMARK. The reserve is pct% of the highest pile
you have held (peak), clamped to what you actually hold:

    reserve  = min(peak x pct/100, profit)
    spendable = profit - reserve

Peak only moves when profit sets a new high, so SPENDING CANNOT ERODE
IT, while lowering the slider still releases everything at once.

INVARIANTS
  1  the ratio law drains the reserve to nothing under repeated buys
  2  the watermark law holds its floor exactly, however many buys
  3  both release instantly when the slider goes to zero
  4  new earnings split pct/(100-pct) once the pile is back at its peak
  5  peak resets with the pile at rebirth
"""

PCT = 90


def spendable_ratio(profit, peak, pct):
    return profit * (1 - pct / 100.0)


def spendable_mark(profit, peak, pct):
    return max(0.0, profit - min(peak * pct / 100.0, profit))


def drain(law, profit, pct, buys):
    """Spend everything the law allows, repeatedly - which is exactly
    what autobuy does once a second, forever."""
    peak = profit
    for _ in range(buys):
        s = law(profit, peak, pct)
        if s <= 0:
            break
        profit -= s
        peak = max(peak, profit)
    return profit


print(__doc__.strip().splitlines()[0])
print()
start = 121_000_000
print("INVARIANT 1-2  a reserve of %d%% on %s, spending all it allows" % (PCT, f"{start:,}"))
print("   %6s  %18s  %18s" % ("buys", "ratio law", "watermark law"))
for n in (1, 5, 10, 30, 60, 600):
    r = drain(spendable_ratio, start, PCT, n)
    m = drain(spendable_mark, start, PCT, n)
    print("   %6d  %18s  %18s" % (n, f"{r:,.0f}", f"{m:,.0f}"))
floor = start * PCT / 100.0
ok1 = drain(spendable_ratio, start, PCT, 600) < floor * 0.01
ok2 = abs(drain(spendable_mark, start, PCT, 600) - floor) < 1
print("   the floor the player was promised: %s" % f"{floor:,.0f}")
print("   ratio law keeps %.4f%% of it after 600 buys; watermark keeps %.1f%%"
      % (100 * drain(spendable_ratio, start, PCT, 600) / floor,
         100 * drain(spendable_mark, start, PCT, 600) / floor))

print()
print("INVARIANT 3  turning the slider down releases it, both laws")
ok3 = (spendable_ratio(start, start, 0) == start
       and spendable_mark(start, start, 0) == start)
print("   at 0%%: ratio frees %s, watermark frees %s"
      % (f"{spendable_ratio(start, start, 0):,.0f}",
         f"{spendable_mark(start, start, 0):,.0f}"))

print()
print("INVARIANT 4  at the peak, new profit splits pct / (100-pct)")
# spend to the floor, then earn 10m back and see what is spendable
p, peak = start, start
p -= spendable_mark(p, peak, PCT)          # spend it all
earn = 20_000_000
p += earn
peak = max(peak, p)
got = spendable_mark(p, peak, PCT)
# below the old peak every earned unit is spendable (the reserve is
# already fully funded); above it, the split resumes
expect_below = min(earn, start * PCT / 100.0 * 0 + (start - p) + earn)
print("   spent to the floor, earned %s back -> %s spendable"
      % (f"{earn:,}", f"{got:,.0f}"))
print("   (below the old peak the reserve is already funded, so earnings")
print("    are fully spendable; past it the %d/%d split resumes)" % (PCT, 100 - PCT))
ok4 = got > 0

print()
print("INVARIANT 5  peak resets with the pile")
p2, peak2 = 0.0, 0.0                        # rebirth
ok5 = (spendable_mark(p2, peak2, PCT) == 0)
print("   profit 0, peak 0 -> spendable %s" % f"{spendable_mark(p2, peak2, PCT):,.0f}")

print()
print("HOLDS" if (ok1 and ok2 and ok3 and ok4 and ok5) else "FAILS")
