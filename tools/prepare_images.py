import os
from PIL import Image, ImageDraw

SRC = "assets/images"
OUT = "assets/ready"

# (kaynak dosya, yeni ad, arka plan silinsin mi, hassasiyet)
FILES = [
    ("1792803328838.jpg", "mascot_main", True, 75),
    ("1792803444566.jpg", "mascot_star", True, 75),
    ("1792803577657.jpg", "mascot_confetti", True, 75),
    ("1792803603706.jpg", "kids", True, 75),
    ("1792803633219.jpg", "girl_hi", True, 25),
    ("1792803666072.jpg", "bg_map", False, 0),
    ("1792803698606.jpg", "bg_london", False, 0),
    ("1792803727662.jpg", "badge_star", True, 75),
    ("1792803752248.jpg", "icon_flame", True, 75),
    ("1792803779595.jpg", "badge_book", True, 75),
    ("1792803920012.jpg", "icon_gem", True, 75),
    ("1792803928598.jpg", "icon_star", True, 30),
    ("1792803990819.jpg", "icon_target", True, 75),
    ("1792804016054.jpg", "icon_gift", True, 75),
    ("1792804048362.jpg", "app_icon", False, 0),
    ("1792804091042.jpg", "mascot_wave", True, 75),
    ("bg_map2_src.jpg", "bg_map2", False, 0),  # Ünite 2 haritası
]

os.makedirs(OUT, exist_ok=True)

for src, name, transparent, thresh in FILES:
    path = os.path.join(SRC, src)
    if not os.path.exists(path):
        print("YOK:", src)
        continue
    img = Image.open(path).convert("RGBA")
    if name == "app_icon":
        img = img.crop((55, 438, 655, 1038))
    if transparent:
        w, h = img.size
        for xy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
            ImageDraw.floodfill(img, xy, (0, 0, 0, 0), thresh=thresh)
    img.save(os.path.join(OUT, name + ".png"))
    print("OK:", name)
    if name == "bg_london":
        # Ana sayfa gokyuzu bolumu sadece ust kismi gosterir: kirpilmis, opak kopya
        # (kucuk ve hizli cizilir). Acilis ekrani tam bg_london'u kullanmaya devam eder.
        img.crop((0, 0, 704, 760)).convert("RGB").save(
            os.path.join(OUT, "bg_hero.png"))
        print("OK: bg_hero")
