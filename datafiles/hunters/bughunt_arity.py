"""Call arity vs declared parameters for every project script function:
too many args = silently ignored (a wrong call); too few = undefined
params (a crash when read). Functions using argument[] are skipped."""
import io, re, glob, os, collections
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
def strip(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s
text = {p: strip(io.open(p, encoding="utf-8", errors="ignore").read()) for p in glob.glob("scripts/*/*.gml") + glob.glob("objects/*/*.gml")}
# declared functions: name -> (min, max) ; max = -1 for variadic (argument[])
sig = {}
for p, s in text.items():
    if not p.startswith("scripts"): continue
    for m in re.finditer(r"\bfunction\s+([A-Za-z_]\w*)\s*\(([^)]*)\)", s):
        name, params = m.group(1), m.group(2).strip()
        body_start = s.find("{", m.end())
        # variadic if the body uses argument[ or argument_count or argumentN
        body = s[body_start:body_start + 20000]
        if re.search(r"\bargument(\[|_count|\d)", body) or params == "":
            if params == "" and re.search(r"\bargument(\[|_count|\d)", body):
                sig[name] = (0, -1); continue
        ps = [x.strip() for x in params.split(",") if x.strip()]
        req = sum(1 for x in ps if "=" not in x)
        sig[name] = (req, len(ps))
def split_args(a):
    out, depth, cur = [], 0, ""
    for ch in a:
        if ch in "([{": depth += 1
        if ch in ")]}": depth -= 1
        if ch == "," and depth == 0: out.append(cur); cur = ""; continue
        cur += ch
    if cur.strip() or out: out.append(cur)
    return [x for x in out]
problems = collections.Counter()
for p, s in text.items():
    for m in re.finditer(r"(?<![\w.$])([A-Za-z_]\w*)\s*\(", s):
        name = m.group(1)
        if name not in sig: continue
        req, mx = sig[name]
        if mx == -1: continue
        # extract the balanced argument text
        i = m.end(); depth = 1; j = i
        while j < len(s) and depth > 0:
            if s[j] == "(": depth += 1
            elif s[j] == ")": depth -= 1
            j += 1
        args = s[i:j - 1]
        n = len(split_args(args)) if args.strip() else 0
        if n < req or n > mx:
            problems[(p, name, n, req, mx)] += 1
for (p, name, n, req, mx), c in sorted(problems.items()):
    print("%-58s %-24s got %d, wants %d..%d  x%d" % (p.replace("\\", "/"), name, n, req, mx, c))
print(len(sig), "functions,", len(problems), "arity problems")
