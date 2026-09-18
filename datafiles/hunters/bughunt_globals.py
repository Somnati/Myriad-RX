"""Globals read but never assigned anywhere (a read of an unset global is a
runtime error in GM 2024)."""
import io, re, glob, collections, os
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
text = {}
for p in glob.glob("scripts/*/*.gml") + glob.glob("objects/*/*.gml"):
    s = io.open(p, encoding="utf-8", errors="ignore").read()
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    text[p] = s
alls = "\n".join(text.values())
reads = collections.defaultdict(set)
for p, s in text.items():
    for m in re.finditer(r"\b(?:g|global)\.([A-Za-z_]\w*)", s):
        reads[m.group(1)].add(p)
assigned = set(re.findall(r"\b(?:g|global)\.([A-Za-z_]\w*)\s*(?:=[^=]|\+=|-=|\*=|/=|\+\+|--)", alls))
assigned |= set(re.findall(r'variable_global_set\(\s*"([A-Za-z_]\w*)"', alls))
assigned |= set(re.findall(r'\b(?:g|global)\[\$\s*"([A-Za-z_]\w*)"\s*\]\s*=', alls))
sus = sorted(n for n in reads if n not in assigned and not n.startswith("ad_") and not n.startswith("__"))
for n in sus:
    files = sorted(p.replace("\\", "/") for p in reads[n])
    print("%-28s %s" % (n, ", ".join(files)[:120]))
print(len(sus), "never-assigned globals read")
