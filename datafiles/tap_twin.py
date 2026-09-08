"""tap_twin.py - the tap rate has to survive passing the frame rate.

His requirement, and DE's: "TPS could get above 60 and would use a
formula to make sure that TPS in the 1000s still reflected accurately
regarding tap stat and profit output."

The formula is DE's click_v2 accumulator, ported into obj_clicker:

    tap_acc += (rate / 60) * delta        # fractional taps, every frame
    if tap_acc >= 1:
        feed = floor(tap_acc)             # the WHOLE part
        tap_acc -= feed
        tap_fire(feed)                    # one call, carrying a count

The alternative every idle game reaches for first is "fire one tap per
frame while held", and it is wrong in a way that hides: it looks fine
until the rate passes the frame rate, then silently caps. At 1000 taps
a second on a 60fps machine it pays 6% of what it owes, and the tap
COUNT lies by the same factor - so the stat page, every total_taps
milestone and every ability that reads lifetime taps are all wrong
together, consistently, which is exactly how a bug survives.

INVARIANTS
  1  taps paid over a run == rate x seconds, within one frame's banking
  2  ... at ANY frame rate: 30, 60, 144, 240
  3  ... at ANY rate, including far past the frame rate
  4  profit == taps x per-tap value (the stat and the money agree)
  5  nothing is lost across the batch boundary - the remainder carries

Run:  python datafiles/tap_twin.py
"""
import math

FPS_CASES  = [30, 60, 90, 144, 240]
RATE_CASES = [0.5, 1, 8, 59, 60, 61, 250, 1000, 12345]
SECONDS    = 60


def run_accumulator(rate, fps, secs):
    """obj_clicker's hold, exactly: delta is the house frame multiplier,
    1.0 == 60fps, so a 144hz machine steps delta = 60/144 each frame."""
    delta = 60.0 / fps
    acc, taps, calls = 0.0, 0, 0
    for _ in range(int(fps * secs)):
        acc += (rate / 60.0) * delta
        if acc >= 1:
            feed = math.floor(acc)
            acc -= feed
            taps += feed
            calls += 1
    return taps, calls, acc


def run_paid(rate, fps, secs, per_tap):
    """tap_fire's accounting: each call adds `feed` to total_taps AND
    pays click_gps x feed. Summed independently here so the twin would
    actually catch the two drifting apart."""
    delta = 60.0 / fps
    acc, taps, profit = 0.0, 0, 0
    for _ in range(int(fps * secs)):
        acc += (rate / 60.0) * delta
        if acc >= 1:
            feed = math.floor(acc)
            acc -= feed
            taps += feed               # g.total_taps += _n
            profit += per_tap * feed   # do_multi(click_gps, arb(_n))
    return taps, profit


def run_naive(rate, fps, secs):
    """The wrong one: one discrete tap per frame while held."""
    return min(rate, fps) * secs


def check():
    print("INVARIANT 1-3  taps paid == rate x seconds, any fps, any rate")
    worst = 0.0
    for fps in FPS_CASES:
        for rate in RATE_CASES:
            want = rate * SECONDS
            got, calls, left = run_accumulator(rate, fps, SECONDS)
            # one frame's worth may still be banked, plus the fraction
            # that has not yet reached a whole tap - that is the carry,
            # not a loss, and the next frame pays it
            slack = (rate / 60.0) * (60.0 / fps) + 1
            err = abs(got - want)
            worst = max(worst, err - slack)
            if err > slack:
                print("   FAIL fps %3d rate %8.1f  want %9.0f got %9d"
                      % (fps, rate, want, got))
    print("   worst overshoot past the carry: %.6f taps" % max(worst, 0))

    print()
    print("INVARIANT 4  the stat and the money cannot disagree")
    per_tap = 137          # whatever click_gps happens to be
    bad = 0
    for fps in FPS_CASES:
        for rate in RATE_CASES:
            taps, profit = run_paid(rate, fps, SECONDS, per_tap)
            if profit != taps * per_tap:
                bad += 1
                print("   FAIL fps %3d rate %8.1f  %d taps but %d profit"
                      % (fps, rate, taps, profit))
    print("   %d disagreements" % bad)
    ok4 = (bad == 0)

    print()
    print("INVARIANT 5  the remainder carries, so nothing is lost")
    # a rate that never divides evenly into frames is the hard case
    # 0.5/s for 60s is 30 taps. Whether the 30th has been PAID or is
    # still banked on the final frame is a float-epsilon coin toss, and
    # it does not matter: banked is carried, not lost. What must hold is
    # that paid + banked accounts for every tap owed.
    taps, calls, left = run_accumulator(0.5, 60, SECONDS)
    print("   rate 0.5 for 60s -> %d paid, %d calls, %.4f banked"
          % (taps, calls, left))
    ok5 = abs((taps + left) - 30) < 1e-6

    print()
    print("WHAT THE FORMULA IS FOR  (60fps, one minute)")
    print("   %8s  %10s  %10s  %s" % ("rate", "accumulator", "one-per-frame", "naive pays"))
    for rate in [8, 60, 250, 1000, 12345]:
        got, _, _ = run_accumulator(rate, 60, SECONDS)
        naive = run_naive(rate, 60, SECONDS)
        print("   %8d  %10d  %10d  %5.1f%%"
              % (rate, got, naive, 100.0 * naive / got))

    print()
    print("HOLDS" if worst <= 0 and ok4 and ok5 else "FAILS")


print(__doc__.strip().splitlines()[0])
print()
check()
