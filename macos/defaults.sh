#!/usr/bin/env bash

# Adjust notification display time
defaults write com.apple.notificationcenterui bannerTime 10

# Don't hide files (the spelling/casing is not a mistake)
defaults write com.apple.Finder AppleSHowAllFiles true

# Enable scroll over icons in the dock
defaults write com.apple.dock scroll-to-open -bool True

# Set the normal, sane, good scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Enable force-click on the trackpad
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool True

# sudo defaults write /Library/Preferences/com.apple.bluetooth ControllerPowerState -int 1

killall dock
