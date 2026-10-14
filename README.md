# Kwar Welcome

Beautiful **Welcome / Hello** dialog on SpringBoard with credit to **Kwar Nu**.

## Dialog

- Dark rounded card  
- Soft blue accent bar  
- **Welcome** title  
- **Hello — glad you're here.**  
- Credit: **Crafted with care by Kwar Nu**  
- **Continue** button  

## Package

- Bundle id: `com.kwarnu.welcome`  
- Injects: SpringBoard only (`KwarWelcome.plist`)  
- Main files: `Sources/KWDialog.m`, `Sources/Tweak.xm`  

## Build

```bash
export THEOS=~/theos
make package
make install
```

Respring — dialog appears after SpringBoard finishes launching.

Requires jailbreak + MobileSubstrate / Substitute / ElleKit.
