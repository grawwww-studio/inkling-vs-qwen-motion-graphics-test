#!/usr/bin/env python3 -I
"""Blind pack for EP12 arm C. Usage: blind_pack_armc.py (after armc.sh ends). Same frame rule as blind_pack.py.
Arm C rendered attempts + 12 decoys (6 Inkling + 6 Qwen-thinking, graded in the first run; seeded draw random.Random(2311)),
re-anonymised under new shuffled ids Y01.. (random.Random(23)); mapping in SEALED-mapping-armc.json. Writes only new names."""
import glob, json, os, random, shutil, subprocess
D = os.path.dirname(os.path.abspath(__file__)); O = f"{D}/blind_armc"; os.makedirs(O, exist_ok=True)
items = []
for lg in sorted(glob.glob(f"{D}/renders/qwennothink_s*/*/log.json")):
    L = json.load(open(lg)); d = os.path.dirname(lg); mp4 = f"{d}/{L['brief']}.mp4"
    if L.get("render_ok") and os.path.exists(mp4): items.append({"kind": "armc", "model": L["model"], "seed": L["seed"], "brief": L["brief"], "mp4": mp4})
old = json.load(open(f"{D}/SEALED-mapping.json")); oldv = json.load(open(f"{D}/blind_verdicts.json.locked"))
rng = random.Random(2311)
for mdl in ("inkling", "qwen"):
    ids = sorted(k for k, v in old.items() if v["model"] == mdl)
    for k in rng.sample(ids, 6):
        items.append({"kind": "decoy", "old_id": k, **old[k], "first_verdict": oldv[k]["verdict"], "first_note": oldv[k]["note"]})
random.Random(23).shuffle(items); mapping = {}
for i, it in enumerate(items):
    aid = f"Y{i+1:02d}"; mapping[aid] = it; mp4 = it["mp4"]
    if it["kind"] == "decoy":
        for ext in ("png", "dur", "brief"): shutil.copy(f"{D}/blind/{it['old_id']}.{ext}", f"{O}/{aid}.{ext}")
        continue
    dur = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", mp4]))
    N = round(dur * 24); fr = sorted({round(N * k / 9) for k in range(1, 9)} | {N - 3})
    vf = "select='" + "+".join(f"eq(n,{n})" for n in fr) + "',scale=640:-1,tile=3x3:padding=4:margin=4"
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", mp4, "-vf", vf, "-vsync", "vfr", "-frames:v", "1", f"{O}/{aid}.png"])
    open(f"{O}/{aid}.dur", "w").write(f"{dur:.2f}\n"); open(f"{O}/{aid}.brief", "w").write(it["brief"] + "\n")
json.dump(mapping, open(f"{D}/SEALED-mapping-armc.json", "w"), indent=1)
print(len(items), "sheets,", sum(1 for x in items if x["kind"] == "armc"), "arm C")
