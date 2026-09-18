"""Brace / paren / bracket balance over every GML file touched in the last
N commits (a crude net for a broken edit)."""
import io, re, subprocess, sys, os
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
n = int(sys.argv[1]) if len(sys.argv) > 1 else 25
files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~%d" % n, "HEAD"], text=True).split()
bad = 0; checked = 0
for f in files:
    if not f.endswith(".gml") or not os.path.exists(f): continue
    s = io.open(f, encoding="utf-8", errors="ignore").read()
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    b = s.count("{") - s.count("}")
    p = s.count("(") - s.count(")")
    k = s.count("[") - s.count("]")
    checked += 1
    if b or p or k:
        print("UNBALANCED", f, "braces", b, "parens", p, "brackets", k); bad += 1
print(checked, "gml files checked,", bad, "unbalanced")
