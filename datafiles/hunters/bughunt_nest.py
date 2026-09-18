"""Nested seeded sections: a script that seeds the stream (random_set_seed
... rng_release / random_set_seed(old)) and, inside, calls another script
that seeds too - the inner release re-seeds the ambient stream, so the
outer's remaining rolls are no longer deterministic (the random_get_seed
rewind, see memory). Lists (outer -> inner) pairs with the outer's rolls
after the call."""
import io, re, glob, os, collections
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
def strip(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s
scripts = {}
for p in glob.glob("scripts/*/*.gml"):
    n = os.path.basename(os.path.dirname(p))
    scripts[n] = strip(io.open(p, encoding="utf-8", errors="ignore").read())
seeders = {n for n, s in scripts.items() if "random_set_seed(" in s}
# does a function seed, transitively (depth 3)?
def seeds_transitive(n, depth=0, seen=None):
    if seen is None: seen = set()
    if n in seen or depth > 3 or n not in scripts: return False
    seen.add(n)
    if n in seeders: return True
    for m in re.findall(r"\b([a-z_][a-z0-9_]*)\s*\(", scripts[n]):
        if m in scripts and m != n and seeds_transitive(m, depth + 1, seen): return True
    return False
ROLL = re.compile(r"\b(random|irandom|random_range|irandom_range|choose|randomize)\s*\(")
out = []
for n in sorted(seeders):
    s = scripts[n]
    i = s.find("random_set_seed(")
    # the section runs to the release (rng_release or random_set_seed(_old/_rs...))
    j = -1
    for m in re.finditer(r"rng_release\(|random_set_seed\(\s*_", s[i + 16:]):
        j = i + 16 + m.start(); break
    if j < 0: j = len(s)
    body = s[i:j]
    for m in re.finditer(r"\b([a-z_][a-z0-9_]*)\s*\(", body):
        f = m.group(1)
        if f == n or f not in scripts: continue
        if seeds_transitive(f):
            after = body[m.end():]
            rolls = len(ROLL.findall(after))
            out.append((n, f, rolls))
seen = set()
for n, f, rolls in out:
    if (n, f) in seen: continue
    seen.add((n, f))
    print("%-24s -> %-24s  rolls after the call in the outer section: %d%s" % (n, f, rolls, "   <-- NON-DETERMINISTIC" if rolls else ""))
print(len(seen), "nested pairs")
