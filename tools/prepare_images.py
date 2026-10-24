import os
from PIL import Image, ImageDraw

SRC = "assets/images"
OUT = "assets/ready"

# (kaynak dosya, yeni ad, arka plan silinsin mi)
FILES = [
    ("1000093747.jpg", "mascot_main", True),
    ("1000093748.jpg", "mascot_star", True),
    ("1000093749.jpg", "mascot_confetti", True),
    ("1000093750.jpg", "kids", True),
    ("1000093751.jpg", "girl_hi", True),
    ("1000093752.jpg", "bg_map", False),
    ("1000093753.jpg", "bg_london", False),
    ("1000093754.jpg", "badge_star", True),
    ("1000093755.jpg", "icon_flame", True),
    ("1000093756.jpg", "badge_book", True),
    ("1000093757.jpg", "icon_gem", True),
    ("1000093758.jpg", "icon_star", True),
    ("1000093759.jpg", "icon_target", True),
    ("1000093760.jpg", "icon_gift", True),
    ("1000093761.jpg", "app_icon", False),
    ("1000093762.jpg", "mascot_wave", True),
]

os.makedirs(OUT, exist_ok=True)

for src, name, transparent in FILES:
    path = os.path.join(SRC, src)
    if not os.path.exists(path):
        print("YOK:", src)
        continue
    img = Image.open(path).convert("RGBA")
    if transparent:
        w, h = img.size
        for xy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
            ImageDraw.floodfill(img, xy, (0, 0, 0, 0), thresh=40)
    img.save(os.path.join(OUT, name + ".png"))
    print("OK:", name)
