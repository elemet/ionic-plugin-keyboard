# Reasons for Wattcost use:
- Used as `disableScroll` was removed from [`cordova-plugin-ionic-keyboard`](https://github.com/ionic-team/cordova-plugin-ionic-keyboard)
- Renamed namespace from `cordova.plugins.Keyboard` to `cordova.plugins.KeyboardUtils` to prevent detection by Ionic-v1, which was breaking iOS Keychain autofill
## Forked to apply fixes:
  - Hardware keyboard auto-blur: https://github.com/ionic-team/ionic-plugin-keyboard/pull/290

### :point_right: Deprecated! Please use [`cordova-plugin-ionic-keyboard`](https://github.com/ionic-team/cordova-plugin-ionic-keyboard) :point_left:

See this comment for API changes needed to move to new plugin: https://github.com/ionic-team/ionic-plugin-keyboard/issues/305#issuecomment-364198332

* Installation, API docs: [README_OLD.md](https://github.com/ionic-team/ionic-plugin-keyboard/blob/master/README_OLD.md)
