# Manual Setup

Things that need to be configured manually (can't be automated or requires GUI).

## First Steps

1. Log in to iCloud
2. Ensure username is correct
3. Run `./install.sh` to install Homebrew, packages, and symlink dotfiles
4. Run `./macos/defaults.sh` to apply system defaults

## System Settings

### Trackpad
1. Point & Click
    1. Click: Light
    2. Tracking speed: 5 of 10
2. More Gestures
    1. App Expose: Swipe down with three fingers

### Keyboard
1. Keyboard Shortcuts
    1. Modifier Keys
        1. Caps Lock: Option

### Security & Privacy
1. FileVault: On (with iCloud recovery)

### Lock Screen
1. Start Screen Saver when inactive: After 5 minutes
2. Require password: After 1 minute

### Touch ID & Password
1. Enroll fingerprints: Right index, Left index, Right thumb
2. Use Touch ID for: All options enabled

### Displays
1. Arrange displays (if multiple)
2. Night Shift
    1. Schedule: Sunset to Sunrise

### Control Center
1. Bluetooth: Show in Menu Bar

### Desktop & Dock
1. Remove Downloads from Dock (handled by defaults.sh for size/position/recents)

## Application Settings

See app-specific docs:
- [Firefox](firefox.md)
- [iTerm2](iterm.md)

### VS Code
1. Sign in with GitHub to sync settings

### 1Password
1. Settings
    1. Security
        1. Unlock
            1. Touch ID: On

### Zoom
1. Settings
    1. Share Screen
        1. Window size when screen sharing: Maximize window
    2. Video
        1. My Video
            1. Stop my video when joining: On

### Messages
1. Settings
    1. Play sound effects: Off
    2. Send read receipts: Off

## SSH Keys

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

Then add to GitHub: https://github.com/settings/keys

## Other Setup Tasks

- [ ] Configure backups (Backblaze, Tarsnap)
- [ ] Set up Obsidian vault syncing
- [ ] Install printer drivers if needed
- [ ] Import Firefox bookmarks (if not synced)
