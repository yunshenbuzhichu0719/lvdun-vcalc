$ErrorActionPreference = 'Continue'
$logfile = 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build\rebuild.log'
"=== rebuild start $(Get-Date -Format 'HH:mm:ss') ===" | Out-File $logfile -Encoding utf8
$JDK = 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build\jdk\bin'
$PLAT = 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build\android-sdk\platforms\android-34'
$BT = 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build\android-sdk\build-tools\34.0.0'
$APK = 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\绿盾V算.apk'

Set-Location 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build'
$env:JAVA_HOME = 'C:\Users\ydyyf\WorkBuddy\2026-08-27-21-52-10\apk-build\jdk'

Write-Host '=== step1 javac ==='
Remove-Item out -Recurse -Force -ErrorAction SilentlyContinue
New-Item out -ItemType Directory -Force | Out-Null
& $JDK\javac.exe -cp "$PLAT\android.jar" -d out app/src/com/volconv/MainActivity.java
Write-Host "javac exit=$LASTEXITCODE"
"step1 javac exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host '=== step2 jar ==='
Remove-Item classes.jar -Force -ErrorAction SilentlyContinue
& $JDK\jar.exe cf classes.jar -C out .
Write-Host "jar exit=$LASTEXITCODE"
"step2 jar exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8

Write-Host '=== step3 d8 ==='
Remove-Item dexdir -Recurse -Force -ErrorAction SilentlyContinue
New-Item dexdir -ItemType Directory -Force | Out-Null
& $JDK\java.exe -cp "$BT\lib\d8.jar" com.android.tools.r8.D8 --min-api 21 --lib "$PLAT\android.jar" --output dexdir classes.jar
Write-Host "d8 exit=$LASTEXITCODE"
"step3 d8 exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8
Copy-Item dexdir\classes.dex . -Force

Write-Host '=== step4 aapt2 link ==='
Remove-Item base.apk -Force -ErrorAction SilentlyContinue
& $BT\aapt2.exe link -o base.apk -I "$PLAT\android.jar" --manifest app/AndroidManifest.xml
Write-Host "aapt2 exit=$LASTEXITCODE"
"step4 aapt2 exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8

Write-Host '=== step5 merge dex+assets ==='
Remove-Item app-unsigned.apk -Force -ErrorAction SilentlyContinue
& 'C:\Users\ydyyf\.workbuddy\binaries\python\versions\3.13.12\python.exe' add_to_apk.py base.apk classes.dex app/assets/index.html app-unsigned.apk
Write-Host "merge exit=$LASTEXITCODE"
"step5 merge exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8

Write-Host '=== step6 zipalign ==='
Remove-Item app-aligned.apk -Force -ErrorAction SilentlyContinue
& $BT\zipalign.exe -p 4 app-unsigned.apk app-aligned.apk
Write-Host "zipalign exit=$LASTEXITCODE"
"step6 zipalign exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8

Write-Host '=== step7 apksigner sign ==='
Remove-Item $APK -Force -ErrorAction SilentlyContinue
& $JDK\java.exe -cp "$BT\lib\apksigner.jar" com.android.apksigner.ApkSignerTool sign --ks keystore.jks --ks-key-alias volconv --ks-pass pass:android --key-pass pass:android --out $APK app-aligned.apk
Write-Host "apksigner exit=$LASTEXITCODE"
"step7 apksigner exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8

Write-Host '=== step8 verify ==='
& $JDK\java.exe -cp "$BT\lib\apksigner.jar" com.android.apksigner.ApkSignerTool verify --verbose $APK *>&1 | Out-File $logfile -Append -Encoding utf8
Write-Host "verify exit=$LASTEXITCODE"
"step8 verify exit=$LASTEXITCODE" | Out-File $logfile -Append -Encoding utf8

Write-Host '=== final size ==='
Get-Item $APK | Select-Object Name, Length | Out-File $logfile -Append -Encoding utf8
"=== rebuild end $(Get-Date -Format 'HH:mm:ss') ===" | Out-File $logfile -Append -Encoding utf8