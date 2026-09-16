"""THE FOE SPRITES (2026-09-16): a 16x16 pixel creature a kind, generated - grayscale tones (tinted the kind's colour in
the game), an inner outline, a highlight band, a white eye. Families by name; a seeded hand per kind. Facing left."""
import io, os, math, random, re
from PIL import Image

R = r"C:\Users\sora0\Desktop\GM Projects\Myriad RX.yyp"
roster = io.open(os.path.join(R, "scripts", "foe_roster", "foe_roster.gml"), encoding="utf-8").read()
KINDS = sorted(set(re.findall(r'name : "([a-z ]+)"', roster)))
assert len(KINDS) >= 30, KINDS

FAM = {
    "rat": ("quad", "small"), "lupus": ("quad", "wolf"), "snow lupus": ("quad", "wolf"), "thos": ("quad", "wolf"),
    "ursus": ("quad", "big"), "nivalis": ("quad", "big"), "capra": ("quad", "horned"), "apero": ("ape", ""),
    "goblin": ("human", "stick"), "bandit": ("human", "hat"), "kobold": ("human", "stick"), "skeleton": ("human", "bones"),
    "ghoul": ("human", "hunch"), "mumia": ("human", "hunch"), "imp": ("human", "horns"), "trollus": ("human", "big"),
    "merrow": ("human", "fins"), "wraith": ("robe", ""), "harpy": ("human", "wings"),
    "slime": ("blob", ""), "hirudo": ("blob", "long"), "paluster": ("blob", "spiky"), "bufo": ("blob", "legs"),
    "vespae": ("fly", "stripes"), "bee": ("fly", "stripes"), "musca": ("fly", ""), "gull": ("fly", "bird"),
    "vulture": ("fly", "bird"), "vesper": ("fly", "bat"), "wisp": ("orb", ""),
    "aranea": ("crawl", "spider"), "scorpio": ("crawl", "tail"), "mudcrab": ("crawl", "claws"), "crab": ("crawl", "claws"),
    "ant": ("crawl", ""), "flea": ("crawl", "small"), "vipera": ("snake", ""), "vermis": ("snake", "thick"), "sand vermis": ("snake", "thick"),
}

W = 16
BODY, DARK, LIGHT, EYE, PUPIL = 158, 70, 215, 255, 20

def canvas(): return [[0] * W for _ in range(W)]
def put(c, x, y, v=BODY):
    x = int(round(x)); y = int(round(y))
    if 0 <= x < W and 0 <= y < W: c[y][x] = v
def ellipse(c, cx, cy, rx, ry, v=BODY):
    for y in range(W):
        for x in range(W):
            if rx > 0 and ry > 0 and ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0: c[y][x] = v
def line(c, x0, y0, x1, y1, v=BODY):
    n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
    for i in range(n + 1):
        t = i / max(1, n); put(c, x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, v)
def rect(c, x0, y0, x1, y1, v=BODY):
    for y in range(int(y0), int(y1) + 1):
        for x in range(int(x0), int(x1) + 1): put(c, x, y, v)

def poly(c, pts, v=BODY):
    n = len(pts)
    for y in range(W):
        xs = []
        for i in range(n):
            x0, y0 = pts[i]; x1, y1 = pts[(i + 1) % n]
            if (y0 <= y + .5 < y1) or (y1 <= y + .5 < y0):
                xs.append(x0 + (y + .5 - y0) * (x1 - x0) / (y1 - y0))
        xs.sort()
        for j in range(0, len(xs) - 1, 2):
            for x in range(int(round(xs[j])), int(round(xs[j + 1])) + 1): put(c, x, y, v)

def finish(c, eye):
    # the inner outline: a body pixel with a bare 4-neighbour goes dark; a highlight under the outline's top edge
    out = [row[:] for row in c]
    for y in range(W):
        for x in range(W):
            if c[y][x] == 0: continue
            bare = False
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if nx < 0 or ny < 0 or nx >= W or ny >= W or c[ny][nx] == 0: bare = True
            if bare: out[y][x] = DARK
    for y in range(1, W):
        for x in range(1, W):
            if out[y][x] == BODY and out[y - 1][x] == DARK and out[y][x - 1] != 0: out[y][x] = LIGHT
    if eye:
        ex, ey = int(round(eye[0])), int(round(eye[1]))
        out[ey][ex] = EYE
        if ex - 1 >= 0 and out[ey][ex - 1] != 0: out[ey][ex - 1] = PUPIL
    return out

def draw_kind(name, rnd):
    fam, var = FAM.get(name, ("quad", "small"))
    c = canvas(); eye = None
    if fam == "quad":
        big = var == "big"; small = var == "small"
        rx = 5 if big else (3 if small else 4); ry = 3 if big else (1.6 if small else 2.2)
        cy = 9.5 if big else 10.5
        ellipse(c, 8.5, cy, rx + rnd.uniform(-.3, .5), ry, BODY)
        hx, hy = 4 - (1 if big else 0), cy - ry + (0.5 if small else 0)
        ellipse(c, hx, hy, 2.2 if not small else 1.7, 1.8 if not small else 1.4)
        for lx in (5, 7, 10, 12) if not small else (6, 8, 10, 11):
            line(c, lx, cy + ry - 1, lx - rnd.choice((0, 1)), 14)
        tl = rnd.randint(2, 4)
        line(c, 8.5 + rx - 1, cy - 1, 8.5 + rx + tl - 1, cy - 1 - tl, BODY)
        put(c, hx - 1, hy - 2); put(c, hx + 1, hy - 2)
        if var == "horned": put(c, hx - 2, hy - 3); put(c, hx - 1, hy - 3); put(c, hx, hy - 3)
        if var == "wolf": put(c, hx - 3, hy + 1); put(c, hx - 4, hy + 1)
        eye = (int(hx) - 1, int(hy))
    elif fam == "ape":
        ellipse(c, 8, 9, 4.5, 3.5); ellipse(c, 5, 5, 2.4, 2.2)
        line(c, 4, 8, 2, 14); line(c, 12, 8, 13, 14); line(c, 7, 12, 6, 14); line(c, 10, 12, 11, 14)
        eye = (4, 5)
    elif fam == "human":
        big = var == "big"; hunch = var == "hunch"
        hr = 2.6 if big else 2.2
        hx, hy = (6.5 if hunch else 7.5), (4.5 if not hunch else 6)
        ellipse(c, hx, hy, hr, hr * .95)
        tw = 2.5 if big else 2
        rect(c, 8 - tw, hy + 2, 8 + tw, 10 if not big else 11)
        rect(c, 8 - tw - 1, hy + 3, 8 - tw, (10 if not hunch else 12)); rect(c, 8 + tw, hy + 3, 8 + tw + 1, 9)
        rect(c, 6, 11 if not big else 12, 7, 14); rect(c, 9, 11 if not big else 12, 10, 14)
        if var == "stick": line(c, 3, 2, 3, 12); put(c, 2, 2); put(c, 4, 2)
        if var == "hat": rect(c, hx - 3, hy - 3, hx + 3, hy - 2); rect(c, hx - 1, hy - 5, hx + 1, hy - 3)
        if var == "horns": put(c, hx - 2, hy - 3); put(c, hx + 2, hy - 3); line(c, 11, 9, 14, 12)
        if var == "wings": line(c, 10, 6, 15, 3); line(c, 10, 7, 15, 5); line(c, 11, 8, 15, 7)
        if var == "fins": put(c, hx, hy - 3); put(c, hx, hy - 4); line(c, 10, 9, 13, 12)
        if var == "bones":
            c2 = canvas()
            for y in range(W):
                for x in range(W):
                    if c[y][x] and not (6 <= y <= 9 and (x + y) % 2 == 1 and 7 <= x <= 9): c2[y][x] = c[y][x]
            c = c2
        eye = (hx - 1, hy)
    elif fam == "robe":
        ellipse(c, 7, 4, 2, 2)
        for y in range(6, 15):
            hw = 1.5 + (y - 6) * 0.45
            rect(c, 8 - hw, y, 8 + hw, y)
        for x in range(3, 14, 3): put(c, x, 14, 0)
        eye = (6, 4)
    elif fam == "blob":
        ry = 3.5 if var != "long" else 2.5; rx = 5 if var != "long" else 6.5
        ellipse(c, 8, 10.5, rx, ry)
        for x in range(3, 14):
            if rnd.random() < .45: put(c, x, 10.5 - ry - 1)
        if var == "spiky":
            for x in range(4, 13, 3): put(c, x, 6); put(c, x, 5)
        if var == "legs":
            line(c, 4, 12, 2, 14); line(c, 12, 12, 14, 14); put(c, 4, 7); put(c, 12, 7)
        eye = (5, 9)
    elif fam == "fly":
        bird = var == "bird"; bat = var == "bat"
        ellipse(c, 8.5, 9, 3.2 if not bird else 3.6, 2)
        ellipse(c, 5, 8.5, 1.8, 1.6)
        if bat:
            poly(c, [(8, 7), (15, 2), (14, 5), (15, 7), (12, 7), (13, 9)])
            poly(c, [(6, 7), (1, 2), (2, 5), (1, 7), (4, 7), (3, 9)])
            put(c, 4, 6); put(c, 6, 6)
        elif bird:
            poly(c, [(7, 7), (14, 2), (15, 4), (10, 8)])
            put(c, 2, 9); put(c, 1, 9)
            line(c, 11, 10, 14, 11)
        else:
            poly(c, [(7, 7), (12, 2), (14, 4), (10, 8)])
            poly(c, [(9, 8), (14, 7), (14, 9), (11, 10)])
            if var == "stripes":
                for x in (8, 10): line(c, x, 8, x, 10, DARK)
            line(c, 3, 9, 1, 9)
        eye = (4, 8)
    elif fam == "orb":
        ellipse(c, 7, 7, 3.2, 3.2)
        for i in range(5): put(c, 10 + i, 8 + i * (1 if rnd.random() < .6 else 0))
        put(c, 5, 6); put(c, 9, 6); eye = (5, 7)
    elif fam == "crawl":
        spider = var == "spider"; small = var == "small"
        rx = 2.4 if small else 3.2; ry = 1.6 if small else 2.2
        ellipse(c, 8 if not spider else 9.5, 10.5, rx, ry)
        if spider: ellipse(c, 5, 10.5, 1.8, 1.6)
        n = 3 if small else 4
        bx = 8 if not spider else 9.5
        for i in range(n):
            t = (i + .5) / n
            line(c, bx - rx + 1, 10.5 - ry + 1 + t * 1.5, bx - rx - 2, 12 + t * 2)
            line(c, bx + rx - 1, 10.5 - ry + 1 + t * 1.5, bx + rx + 2, 12 + t * 2)
        if var == "tail":
            line(c, 11, 9, 14, 6); put(c, 14, 5); put(c, 13, 5)
        if var == "claws":
            put(c, 3, 9); put(c, 2, 8); put(c, 3, 8); put(c, 13, 9); put(c, 14, 8); put(c, 13, 8)
        eye = (5 if not spider else 4, 10)
    elif fam == "snake":
        thick = var == "thick"
        pts = [(2, 13), (4, 11), (7, 12), (10, 13), (13, 11), (14, 8)]
        for i in range(len(pts) - 1):
            x0, y0 = pts[i]; x1, y1 = pts[i + 1]
            line(c, x0, y0, x1, y1); line(c, x0, y0 - 1, x1, y1 - 1)
            if thick: line(c, x0, y0 + 1, x1, y1 + 1)
        ellipse(c, 2.5, 12, 2.2, 1.7)
        eye = (2, 12)
    return finish(c, eye)

def to_png(c):
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    px = im.load()
    for y in range(W):
        for x in range(W):
            v = c[y][x]
            if v: px[x, y] = (v, v, v, 255)
    return im

frames = []
for i, name in enumerate(KINDS):
    rnd = random.Random(sum(ord(ch) * (k + 1) for k, ch in enumerate(name)))
    frames.append((name, to_png(draw_kind(name, rnd))))

# the sprite resource (spr_star_glow's .yy as the template)
base = os.path.join(R, "sprites", "spr_foe")
import shutil
if os.path.isdir(base): shutil.rmtree(base)
os.makedirs(os.path.join(base, "layers"))
ids = ["f0e0%04d-4444-4444-8444-%012d" % (i + 1, i + 1) for i in range(len(frames))]
layer = "f0e000ee-5555-4555-8555-0000000000ee"
for (name, im), fid in zip(frames, ids):
    im.save(os.path.join(base, fid + ".png"))
    os.makedirs(os.path.join(base, "layers", fid))
    im.save(os.path.join(base, "layers", fid, layer + ".png"))
Y = io.open(os.path.join(R, "sprites", "spr_star_glow", "spr_star_glow.yy"), encoding="utf-8").read()
Y = Y.replace("spr_star_glow", "spr_foe")
Y = Y.replace('"bbox_bottom":23', '"bbox_bottom":15').replace('"bbox_right":23', '"bbox_right":15')
Y = Y.replace('"height":24', '"height":16').replace('"width":24', '"width":16')
Y = Y.replace('"xorigin":12', '"xorigin":8').replace('"yorigin":12', '"yorigin":8')
Y = Y.replace('"length":6.0', '"length":%d.0' % len(frames))
Y = Y.replace("de5ad0ee-7777-4777-8777-00000000cccc", layer)
i0 = Y.index('  "frames":['); i1 = Y.index("  ],\n", i0) + len("  ],\n")
fr = '  "frames":[\n' + "".join('    {"$GMSpriteFrame":"v1","%%Name":"%s","name":"%s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},\n' % (f, f) for f in ids) + "  ],\n"
Y = Y[:i0] + fr + Y[i1:]
k0 = Y.index('"Keyframes":[\n            {"$Keyframe<SpriteFrameKeyframe>"'); k1 = Y.index("          ],", k0)
kf = '"Keyframes":[\n' + "".join('            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{"0":{"$SpriteFrameKeyframe":"","Id":{"name":"%s","path":"sprites/spr_foe/spr_foe.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},},"Disabled":false,"id":"f0e0%04d-6666-4666-8666-%012d","IsCreationKey":false,"Key":%d.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},\n' % (f, i + 1, i + 1, i) for i, f in enumerate(ids))
Y = Y[:k0] + kf + Y[k1:]
assert Y.count("de5a") == 0
io.open(os.path.join(base, "spr_foe.yy"), "w", encoding="utf-8", newline="\n").write(Y)

# the contact sheet, tinted a few ways
sheet = Image.new("RGBA", (len(frames) * 52, 60), (18, 18, 28, 255))
for i, (name, im) in enumerate(frames):
    up = im.resize((48, 48), Image.NEAREST)
    tint = Image.new("RGBA", up.size, (230, 170, 110, 255))
    tinted = Image.composite(tint, Image.new("RGBA", up.size, (0, 0, 0, 0)), up.split()[3])
    # multiply the gray by the tint
    t = up.copy(); tp = t.load(); ip = up.load()
    for y in range(48):
        for x in range(48):
            r, g, b, a = ip[x, y]
            tp[x, y] = (r * 230 // 255, g * 170 // 255, b * 110 // 255, a)
    sheet.alpha_composite(t, (i * 52 + 2, 6))
out = r"C:\Users\sora0\AppData\Local\Temp\claude\C--Users-sora0-Desktop-GM-Projects-Techdemo-II-techdemo-yyp\a1af3222-06a9-4a05-957c-f45ba93974de\scratchpad\foe_sheet.png"
sheet.save(out)
io.open(out + ".kinds.txt", "w").write("\n".join(KINDS))
print(len(frames), "frames;", ", ".join(KINDS))
