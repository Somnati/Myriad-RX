"""Every object's event FILES vs its .yy eventList: a file with no entry is
an event that never runs; an entry with no file is a missing event."""
import io, os, re, glob
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
# eventType/eventNum -> filename
def fname(t, n):
    names = {0: "Create", 1: "Destroy", 2: "Alarm", 3: "Step", 4: "Collision", 5: "Keyboard", 6: "Mouse", 7: "Other", 8: "Draw", 9: "KeyPress", 10: "KeyRelease", 12: "CleanUp", 13: "Gesture"}
    return "%s_%d.gml" % (names.get(t, "Ev%d" % t), n)
bad = 0
for yy in glob.glob("objects/*/*.yy"):
    d = os.path.dirname(yy)
    s = io.open(yy, encoding="utf-8").read()
    listed = set()
    for m in re.finditer(r'"eventNum":(\d+),"eventType":(\d+)', s):
        listed.add(fname(int(m.group(2)), int(m.group(1))))
    files = set(os.path.basename(p) for p in glob.glob(d + "/*.gml"))
    for f in files - listed:
        print("FILE WITHOUT EVENT ENTRY:", d, f); bad += 1
    for f in listed - files:
        print("EVENT ENTRY WITHOUT FILE:", d, f); bad += 1
print(bad, "mismatches across", len(glob.glob("objects/*/*.yy")), "objects")
