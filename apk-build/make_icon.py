from PIL import Image, ImageDraw
import os

def make_icon():
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    top = (46, 125, 50)    # #2E7D32
    bot = (76, 175, 80)    # #4CAF50
    # 渐变背景（竖向）
    for y in range(size):
        t = y / (size - 1)
        col = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
        d.line([(0, y), (size, y)], fill=col + (255,))
    # 圆角遮罩（四角透明）
    mask = Image.new('L', (size, size), 0)
    md = ImageDraw.Draw(mask)
    rad = int(size * 0.20)
    md.rounded_rectangle([0, 0, size, size], radius=rad, fill=255)
    img.putalpha(mask)

    sd = ImageDraw.Draw(img)
    # 白色盾牌
    sd.polygon([
        (size * 0.30, size * 0.17),
        (size * 0.70, size * 0.17),
        (size * 0.70, size * 0.52),
        (size * 0.50, size * 0.83),
        (size * 0.30, size * 0.52),
    ], fill=(255, 255, 255, 255))
    # 盾牌内绿色 V
    vw = max(10, int(size * 0.05))
    green = (46, 125, 50, 255)
    sd.line([(size * 0.37, size * 0.31), (size * 0.50, size * 0.60)],
            fill=green, width=vw, joint='curve')
    sd.line([(size * 0.50, size * 0.60), (size * 0.63, size * 0.31)],
            fill=green, width=vw, joint='curve')
    return img

densities = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}
base = r'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build\app\res'
hi = make_icon()
for name, sz in densities.items():
    d = os.path.join(base, name)
    os.makedirs(d, exist_ok=True)
    im = hi.resize((sz, sz), Image.LANCZOS)
    im.save(os.path.join(d, 'ic_launcher.png'))
print('icons written to', base)
