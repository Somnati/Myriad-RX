"""hunt.py - THE STATIC HUNTERS, one verdict (q226).

Runs every hunter in datafiles/hunters/ over the project and compares what
they print against datafiles/hunt_baseline.txt - the findings we have read
and judged benign (a `with` block's fields, a struct-literal method's self,
a comma declaration the svars hunter cannot see). A finding NOT in the
baseline is NEW and fails the gate; a baseline line no longer produced is
reported as gone (nothing fails). validate_project.py calls this, so every
round's pre-flight carries the hunters too - the hunters live in the repo,
not in a chat's scratchpad, and the baseline travels with the code.

  python datafiles/hunt.py             run, report new / gone, exit 1 on new
  python datafiles/hunt.py --accept    rewrite the baseline from this run
  python datafiles/hunt.py --show      print every finding (the whole set)

A hunter is any datafiles/hunters/bughunt*.py plus undef_scan.py (over the
expedition panel and its views); each prints one finding a line and a
summary line the runner strips. The shader compile (glsl_check.py) is
validate_project.py's own step, not a hunter: it has no baseline to keep.
"""
import io, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HUNT = os.path.join(ROOT, "datafiles", "hunters")
BASE = os.path.join(ROOT, "datafiles", "hunt_baseline.txt")
PY = sys.executable

HUNTERS = [
    ("calls",   ["bughunt.py"]),
    ("arity",   ["bughunt_arity.py"]),
    ("events",  ["bughunt_events.py"]),
    ("nest",    ["bughunt_nest.py"]),
    ("globals", ["bughunt_globals.py"]),
    ("fields",  ["bughunt_fields.py"]),
    ("svars",   ["bughunt_svars.py"]),
    ("ivars",   ["bughunt_ivars.py"]),
    ("dupvar",  ["bughunt_dupvar.py"]),
    ("undef",   ["undef_scan.py", ROOT, "objects/syst_exped_panel/*.gml", "scripts/ex_*/*.gml"]),
]
# the summary lines every hunter ends with - counts, not findings
SUMMARY = re.compile(r"^(\d+ (functions|mismatches|nested|never-assigned|suspects|duplicates|gml files)|builtins \d+|done$|files \d+ used \d+)")


def run(name, argv):
    p = subprocess.run([PY, os.path.join(HUNT, argv[0])] + argv[1:], cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace")
    out = (p.stdout or "") + (("\n[stderr] " + p.stderr.strip()) if p.returncode != 0 and p.stderr else "")
    lines = set()
    for l in out.split("\n"):
        l = l.rstrip()
        if not l or SUMMARY.match(l): continue
        lines.add(l)
    return lines, p.returncode


def main():
    accept = "--accept" in sys.argv
    show = "--show" in sys.argv
    found = {}
    broken = []
    for name, argv in HUNTERS:
        lines, rc = run(name, argv)
        if rc != 0: broken.append(name)
        found[name] = lines
    base = {}
    if os.path.exists(BASE):
        for l in io.open(BASE, encoding="utf-8").read().split("\n"):
            if "\t" not in l: continue
            k, v = l.split("\t", 1)
            base.setdefault(k, set()).add(v)
    new, gone = [], []
    for name, _ in HUNTERS:
        for l in sorted(found[name] - base.get(name, set())): new.append((name, l))
        for l in sorted(base.get(name, set()) - found[name]): gone.append((name, l))
    if show:
        for name, _ in HUNTERS:
            for l in sorted(found[name]): print(f"{name:8} {l}")
    total = sum(len(v) for v in found.values())
    if accept:
        with io.open(BASE, "w", encoding="utf-8", newline="\n") as f:
            for name, _ in HUNTERS:
                for l in sorted(found[name]): f.write(f"{name}\t{l}\n")
        print(f"baseline accepted: {total} findings across {len(HUNTERS)} hunters")
        return 0
    for name, l in new: print(f"  NEW   {name:8} {l}")
    for name, l in gone: print(f"  gone  {name:8} {l}")
    for name in broken: print(f"  BROKE {name} (the hunter itself failed - see its stderr above)")
    print(f"hunters: {total} findings, {len(new)} new, {len(gone)} gone" + (f", {len(broken)} broken" if broken else ""))
    return 1 if (new or broken) else 0


if __name__ == "__main__":
    sys.exit(main())
