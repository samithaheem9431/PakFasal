import json
from pathlib import Path
dir = Path(r"d:\pakfasal_app\assets\lottie\_candidates")
for p in sorted(dir.glob("*.json")):
    try:
        d = json.loads(p.read_text(encoding="utf-8"))
    except Exception as e:
        print(p.name, "BAD", e)
        continue
    assets = d.get("assets") or []
    layers = d.get("layers") or []
    names = [L.get("nm","") for L in layers][:10]
    print(f"{p.name}: {p.stat().st_size}B nm={d.get('nm')} {d.get('w')}x{d.get('h')} layers={len(layers)} assets={len(assets)} names={names}")
