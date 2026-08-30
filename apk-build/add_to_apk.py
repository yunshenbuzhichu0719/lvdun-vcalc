"""Add classes.dex and HTML asset to a base APK and write unsigned APK."""
import sys, os, zipfile, shutil

if len(sys.argv) != 5:
    print('Usage: add_to_apk.py <base.apk> <classes.dex> <index.html> <out.apk>')
    sys.exit(1)

base, dex, html, out = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
tmp = out + '.tmp'

with zipfile.ZipFile(base, 'r') as zin, zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
    for n in zin.namelist():
        zout.writestr(n, zin.read(n))
    zout.write(dex, 'classes.dex')
    zout.write(html, 'assets/index.html')

shutil.move(tmp, out)
print('merged apk:', out, os.path.getsize(out), 'bytes')