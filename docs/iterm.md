# iTerm2 Setup

Note: Opening iTerm2 triggers installation of Xcode Command Line Tools.

## What's automated

**Profile settings** (`iterm/profiles.json` — dynamic profile, symlinked by `install.sh`):
- Catppuccin Mocha color scheme (all 16 ANSI colors + UI colors)
- Font: FiraCode Nerd Font Mono 12
- Working directory: `~/dev`
- Silence bell, unlimited scrollback, cursor guide

**Appearance settings** (`macos/defaults.sh`):
- Split pane dimming: 15%, text only
- Tab bar: always visible, not stretched

## Manual steps

After running `install.sh`, set the dynamic profile as default:

1. Open iTerm2 Settings > Profiles
2. Select "Catppuccin Mocha"
3. Other Actions > Set as Default

## Window arrangements

Window arrangements are machine-specific (screen sizes, pixel positions) and not tracked in git.

To back up all iTerm2 settings (including arrangements):
```bash
defaults export com.googlecode.iterm2 ~/iterm2-backup.plist
```

To restore:
```bash
defaults import com.googlecode.iterm2 ~/iterm2-backup.plist
```

You can also save/restore specific arrangements via iTerm2's GUI:
Window > Save Window Arrangement / Restore Window Arrangement.
