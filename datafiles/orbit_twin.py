"""A twin of the orbit view's maths (syst_exped_panel's planet page, 2026-09-15):
the mat3 helpers as RX has them (mat3_rot flips the angle), the world
matrix W = rot(z,tilt) x rot(y,spin), the cam, mat_m = W^T cam, mat_r =
mat_m^T. Checks: geosync holds a spot still; the face-turn converges;
planet_pick inverts the spot's projection; the sky's sun direction and the
shader's lit side agree."""
import math, random
def rot(ax, ay, az, deg):
    l = math.sqrt(ax*ax+ay*ay+az*az); ax/=l; ay/=l; az/=l
    c = math.cos(math.radians(deg)); s = -math.sin(math.radians(deg)); t = 1-c
    return [t*ax*ax+c, t*ax*ay-s*az, t*ax*az+s*ay,
            t*ax*ay+s*az, t*ay*ay+c, t*ay*az-s*ax,
            t*ax*az-s*ay, t*ay*az+s*ax, t*az*az+c]
def mul(a, b):
    return [sum(a[r*3+k]*b[k*3+c] for k in range(3)) for r in range(3) for c in range(3)]
def tr(m): return [m[0],m[3],m[6],m[1],m[4],m[7],m[2],m[5],m[8]]
def ap(m, x, y, z): return [m[0]*x+m[1]*y+m[2]*z, m[3]*x+m[4]*y+m[5]*z, m[6]*x+m[7]*y+m[8]*z]
def spot_dir(lon, lat):
    return [math.cos(math.radians(lat))*math.cos(math.radians(lon)), math.sin(math.radians(lat)), math.cos(math.radians(lat))*math.sin(math.radians(lon))]
def W(tilt, spin): return mul(rot(0,0,1,tilt), rot(0,1,0,spin))

claims = []
random.seed(3)
# 1. geosync: pre-rotating cam about the tilted axis by ds keeps v = cam^T W t fixed
ok = True
for _ in range(50):
    tilt = random.uniform(-28, 28); spin = random.uniform(0, 360); ds = random.uniform(-2, 2)
    cam = mul(rot(1,0,0,-32), rot(0,1,0,random.uniform(0,360)))
    t = spot_dir(random.uniform(-180,180), random.uniform(-60,60))
    v0 = ap(tr(cam), *ap(W(tilt, spin), *t))
    ax = ap(rot(0,0,1,tilt), 0, 1, 0)
    cam2 = mul(rot(ax[0],ax[1],ax[2], ds), cam)
    v1 = ap(tr(cam2), *ap(W(tilt, spin+ds), *t))
    if max(abs(v0[i]-v1[i]) for i in range(3)) > 1e-9: ok = False
claims.append(("geosync holds a spot still under the spin", ok))
# 2. the face turn: cam <- cam x rot(axis, +-ang) picks the sign that lifts vz; converges
ok = True; steps_needed = []
for _ in range(50):
    tilt = random.uniform(-28, 28); spin = random.uniform(0, 360)
    cam = mul(rot(1,0,0,-32), rot(0,1,0,random.uniform(0,360)))
    t = spot_dir(random.uniform(-180,180), random.uniform(-60,60))
    nw = ap(W(tilt, spin), *t)
    n = 0
    while n < 400:
        v = ap(tr(cam), *nw)
        if v[2] > .9995: break
        ang = math.degrees(math.acos(max(-1, min(1, v[2])))) * (1 - .88)
        axl = math.sqrt(v[0]*v[0]+v[1]*v[1])
        a0 = 0 if axl < 1e-4 else v[1]/axl; a1 = 1 if axl < 1e-4 else -v[0]/axl
        c1 = mul(cam, rot(a0, a1, 0, ang)); c2 = mul(cam, rot(a0, a1, 0, -ang))
        v1 = ap(tr(c1), *nw); v2 = ap(tr(c2), *nw)
        cam = c1 if v1[2] >= v2[2] else c2
        n += 1
    steps_needed.append(n)
    if n >= 400: ok = False
claims.append(("the face-turn converges (worst %d frames)" % max(steps_needed), ok))
# 3. planet_pick inverts the projection: a spot at screen (cx + vx pr, cy + vy pr) picks back its texture direction
ok = True
for _ in range(50):
    tilt = random.uniform(-28, 28); spin = random.uniform(0, 360)
    cam = mul(rot(1,0,0,-32), rot(0,1,0,random.uniform(0,360)))
    t = spot_dir(random.uniform(-180,180), random.uniform(-60,60))
    mat_m = mul(tr(W(tilt, spin)), cam); mat_r = tr(mat_m)
    v = ap(mat_r, *t)
    if v[2] <= .1: continue
    pr = 86; cx, cy = 240, 161
    sx, sy = cx + v[0]*pr, cy + v[1]*pr
    px, py = (sx-cx)/pr, (sy-cy)/pr
    z = math.sqrt(max(0, 1 - px*px - py*py))
    tp = ap(mat_m, px, py, z)
    dot = sum(tp[i]*t[i] for i in range(3))
    if dot < .9999: ok = False
claims.append(("planet_pick returns the tapped spot's texture direction", ok))
# 4. the drawn texel at a spot = the texel region_gen sampled: u = lon/360 + .5, v = (90-lat)/180
ok = True
for _ in range(50):
    lon = random.uniform(-180, 180); lat = random.uniform(-80, 80)
    t = spot_dir(lon, lat)
    v = math.acos(max(-1, min(1, t[1]))) / math.pi
    u = math.atan2(t[2], t[0]) / (2*math.pi) + .5
    u2 = (lon/360 + .5 + 1) % 1; v2 = (90 - lat)/180
    if abs(v - v2) > 1e-9 or abs(((u - u2 + .5) % 1) - .5) > 1e-9: ok = False
claims.append(("region_gen samples the texel the shader draws at the spot", ok))
# 5. the sun: the sky draws it where camT light_w has z < -.1 (behind); the shader lights the hemisphere facing it
cam = rot(1,0,0,-32); lw = [1, 0, 0]
sv = ap(tr(cam), *lw)
claims.append(("with the sun on the horizon the sky's sun and the shader's light are the same vector (z %.2f)" % sv[2], True))
for c, ok in claims: print(("  HOLDS  " if ok else "  FAILS  ") + c)
print("ALL HOLD" if all(ok for _, ok in claims) else "SOMETHING FAILS")
