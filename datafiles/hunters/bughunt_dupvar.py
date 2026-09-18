"""Duplicate `var` declarations in one event / script (Feather's 'Local
variable already declared' - a warning that compiles, but he reads the
warnings pane). Lists each file's names declared more than once."""
import io, re, glob, os, collections, sys
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
def strip(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s
only = sys.argv[1] if len(sys.argv) > 1 else ""
files = glob.glob("objects/*/*.gml") + glob.glob("scripts/*/*.gml")
total = 0
for p in sorted(files):
    if only and only not in p: continue
    s = strip(io.open(p, encoding="utf-8", errors="ignore").read())
    # function bodies are their own scope: split scripts per top-level function
    chunks = re.split(r"\bfunction\s+[A-Za-z_]\w*\s*\(", s) if p.startswith("scripts") else [s]
    for ch in chunks:
        # function LITERALS inside are their own scope too: drop them crudely
        ch2 = re.sub(r"function\s*\([^)]*\)\s*\{", "function(){", ch)
        names = collections.Counter()
        for m in re.finditer(r"\bvar\s+([^;{}]*)", ch2):
            for part in m.group(1).split(","):
                mm = re.match(r"\s*([A-Za-z_]\w*)", part)
                if mm: names[mm.group(1)] += 1
        dup = sorted(n for n, c in names.items() if c > 1)
        if dup:
            total += len(dup)
            print("%-52s %s" % (p, " ".join(dup)))
print(total, "duplicates")
