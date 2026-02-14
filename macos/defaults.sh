#!/usr/bin/env bash
# macOS system preferences
# Run this script to apply settings, then log out/restart for all changes to take effect

set -euo pipefail

echo "Applying macOS defaults..."

# Close System Preferences to prevent it from overriding settings
osascript -e 'tell application "System Preferences" to quit'

# Ask for sudo upfront
sudo -v

# =============================================================================
# Appearance
# =============================================================================

# Auto switch between light and dark mode
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# =============================================================================
# Sound
# =============================================================================

# Disable startup sound
sudo nvram StartupMute=%01

# Disable UI sound effects
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

# =============================================================================
# Keyboard
# =============================================================================

# Fast key repeat (1 = fastest)
defaults write -g KeyRepeat -int 1

# Short delay until repeat (15 = shortest)
defaults write -g InitialKeyRepeat -int 15

# Disable auto-period with double space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# =============================================================================
# Dock
# =============================================================================

# Small icon size
defaults write com.apple.dock tilesize -int 24

# Position on left
defaults write com.apple.dock orientation -string "left"

# Don't show recent applications
defaults write com.apple.dock show-recents -bool false

# Group windows by application in Mission Control (for Aerospace)
defaults write com.apple.dock expose-group-apps -bool true

# =============================================================================
# Finder
# =============================================================================

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Use column view by default
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# =============================================================================
# Trackpad
# =============================================================================

# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Disable swipe between pages
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

# =============================================================================
# Menu Bar
# =============================================================================

# Reduce menu bar icon spacing (optional)
# defaults -currentHost write -globalDomain NSStatusItemSpacing -int 12
# defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 8

# =============================================================================
# iTerm2
# =============================================================================

# Dim split panes slightly
defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -float 0.15

# Only dim text, not background
defaults write com.googlecode.iterm2 DimOnlyText -bool true

# Show tab bar even with one tab
defaults write com.googlecode.iterm2 HideTab -bool false

# Don't stretch tabs to fill bar
defaults write com.googlecode.iterm2 StretchTabsToFillBar -bool false

# =============================================================================
# Apply changes
# =============================================================================

echo "Restarting affected applications..."
for app in "Finder" "Dock"; do
    killall "${app}" &> /dev/null || true
done

echo "Done. Some changes may require a logout/restart to take effect."
