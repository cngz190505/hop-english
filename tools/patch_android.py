"""flutter create'ten SONRA calisir (build.yml): uygulama simgesi, acilis ekrani rengi, uygulama adi.
Ek paket yok, sadece Pillow. Calisma klasoru: proje koku."""
import os
import re
from PIL import Image

MAIN = "android/app/src/main"
RES = MAIN + "/res"
COLOR = "#389BED"  # acilis ekranindaki gokyuzu mavisi (welcome_screen ust rengi)
NAME = "Hop English"

# 1) Uygulama simgesi: assets/ready/app_icon.png -> mipmap klasorleri
SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
src = Image.open("assets/ready/app_icon.png").convert("RGB")
m = int(src.width * 0.02)  # kose kenar boslugunu kes
src = src.crop((m, m, src.width - m, src.height - m))
for d, px in SIZES.items():
    folder = "%s/mipmap-%s" % (RES, d)
    os.makedirs(folder, exist_ok=True)
    src.resize((px, px), Image.LANCZOS).save(folder + "/ic_launcher.png")
    # varsa yuvarlak surum de ayni simge olsun
    if os.path.exists(folder + "/ic_launcher_round.png"):
        src.resize((px, px), Image.LANCZOS).save(folder + "/ic_launcher_round.png")
# Sablonda uyarlanabilir (adaptive) simge XML'i varsa, bizim PNG'yi golgede birakmasin
for dp, _, files in os.walk(RES):
    if "anydpi" in dp:
        for f in files:
            if f.startswith("ic_launcher") and f.endswith(".xml"):
                os.remove(os.path.join(dp, f))

# 2) Acilis arka plani: her yerde duz mavi (karanlik modda siyah olmasin)
LB = ('<?xml version="1.0" encoding="utf-8"?>\n'
      '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n'
      '    <item>\n'
      '        <shape android:shape="rectangle">\n'
      '            <solid android:color="%s" />\n'
      '        </shape>\n'
      '    </item>\n'
      '</layer-list>\n' % COLOR)
found = False
for dp, _, files in os.walk(RES):
    if "launch_background.xml" in files:
        open(os.path.join(dp, "launch_background.xml"), "w", encoding="utf8").write(LB)
        found = True
if not found:
    os.makedirs(RES + "/drawable", exist_ok=True)
    open(RES + "/drawable/launch_background.xml", "w", encoding="utf8").write(LB)

# 3) Stiller: karanlik mod temasi siyah degil acik olsun, Android 12 acilis rengi mavi
for dp, _, files in os.walk(RES):
    if not os.path.basename(dp).startswith("values") or "styles.xml" not in files:
        continue
    p = os.path.join(dp, "styles.xml")
    s = open(p, encoding="utf8").read()
    s = s.replace("Theme.Black.NoTitleBar", "Theme.Light.NoTitleBar")
    s = s.replace("?android:colorBackground", "@drawable/launch_background")
    item = '<item name="android:windowSplashScreenBackground">%s</item>' % COLOR

    def add(mo):
        body = mo.group(2)
        if "windowSplashScreenBackground" not in body:
            body = body.rstrip() + "\n        " + item + "\n    "
        return mo.group(1) + body + mo.group(3)

    s = re.sub(r'(<style name="LaunchTheme"[^>]*>)(.*?)(</style>)', add, s, flags=re.S)
    open(p, "w", encoding="utf8").write(s)

# 4) Uygulama adi (telefonda "hop_english" yerine "Hop English")
mp = MAIN + "/AndroidManifest.xml"
t = open(mp, encoding="utf8").read()
t = re.sub(r'android:label="[^"]*"', 'android:label="%s"' % NAME, t, count=1)
open(mp, "w", encoding="utf8").write(t)
print("Android yamalari tamam: simge, acilis rengi, uygulama adi")

# 5) Impeller kapali (Skia): bazi Xiaomi/Redmi telefonlarda Impeller (Vulkan) kaydirma/yaylanmada
#    kare atlatiyor. Ana sayfadaki titreme icin deney; duzelmezse bu bolum kaldirilir.
mt = open(mp, encoding="utf8").read()
if "EnableImpeller" not in mt:
    mt = mt.replace(
        "<application",
        "<application", 1)
    mt = re.sub(
        r"(<application[^>]*>)",
        r'\1\n        <meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false" />',
        mt, count=1)
    open(mp, "w", encoding="utf8").write(mt)
print("Impeller kapatildi (Skia)")
