from pathlib import Path
from collections import deque
from PIL import Image

DST = Path(r"d:\pakfasal_app\assets\images\dashboard")

JOBS = [
    ("tile_weather.png", "tile_weather.png", "white"),
    ("tile_sensor.jpg", "tile_sensor.png", "black"),
    ("tile_ask_ai.jpg", "tile_ask_ai.png", "white"),
    ("tile_crop_calendar.jpg", "tile_crop_calendar.png", "black"),
    ("tile_marketplace.jpg", "tile_marketplace.png", "white"),
    ("tile_learning.jpg", "tile_learning.png", "black"),
]

TOL = {
    "white": (45, 90),  # hard, soft
    "black": (35, 70),
}


def color_dist(c, target):
    return abs(c[0] - target[0]) + abs(c[1] - target[1]) + abs(c[2] - target[2])


def flood_remove(img, mode, hard_tol, soft_tol):
    """Remove background connected to image edges. Soft fringe gets partial alpha."""
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    target = (255, 255, 255) if mode == "white" else (0, 0, 0)

    visited = [[False] * w for _ in range(h)]
    q = deque()

    def try_enqueue(x, y):
        if x < 0 or y < 0 or x >= w or y >= h or visited[y][x]:
            return
        r, g, b, _a = px[x, y]
        d = color_dist((r, g, b), target)
        if d <= soft_tol:
            visited[y][x] = True
            q.append((x, y))

    for x in range(w):
        try_enqueue(x, 0)
        try_enqueue(x, h - 1)
    for y in range(h):
        try_enqueue(0, y)
        try_enqueue(w - 1, y)

    while q:
        x, y = q.popleft()
        r, g, b, _a = px[x, y]
        d = color_dist((r, g, b), target)
        if d <= hard_tol:
            px[x, y] = (r, g, b, 0)
        else:
            t = (d - hard_tol) / max(1, soft_tol - hard_tol)
            alpha = int(max(0, min(255, t * 255)))
            px[x, y] = (r, g, b, alpha)
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            try_enqueue(nx, ny)

    return img


def main():
    for src_name, out_name, mode in JOBS:
        src = DST / src_name
        out = DST / out_name
        hard, soft = TOL[mode]
        result = flood_remove(Image.open(src), mode, hard, soft)
        result.save(out, "PNG", optimize=True)
        hist = result.getchannel("A").histogram()
        print(
            f"{out_name}: {result.size} transparent={hist[0]} "
            f"opaque~={sum(hist[250:])} mode={mode}"
        )
    print("done")


if __name__ == "__main__":
    main()
