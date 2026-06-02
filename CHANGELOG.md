# Changelog

## 1.0.44

- Fixed standalone mini-app layout not resizing after runtime orientation changes (portrait ↔ landscape) when the page is already opened.
- Added runtime relayout fallback in `AttachmentController` to re-apply `ContainerViewLayout` using current `windowScene` bounds and safe-area insets when geometry changes are detected.
- Corrected `WebAppController` web view custom inset assignment (`right` now uses `layout.safeInsets.right`) to avoid asymmetric layout after rotation.

## 1.0.43

- Fixed video fullscreen not becoming visible in standalone mini-app mode by adjusting overlay window layering.
- Updated standalone presentation to use host window bounds and set `overlayWindow.windowLevel` to `UIWindow.Level.normal, avoiding conflicts with system fullscreen video window.

## 1.0.42

- Added token expiration persistence and expiration check in session management
- Auto-clears expired local auth data on startup

## 1.0.41

- Added Swift Package Manager support via `Package.swift` for `MiniAppX`.
- Declared SPM dependency on `MiniAppUIKit` (`miniapp-lib-uikit`) while keeping CocoaPods compatibility in parallel.
- Configured package metadata for iOS 13+ and localized resources (`defaultLocalization`), and included `MiniAppXResources.bundle` through SPM resources.
- Updated resource loading logic in `UIKitResourceBundle` to use `Bundle.module` under SPM and preserve legacy fallback behavior for non-SPM integration.
- Verified package manifest resolution/build graph with SwiftPM tooling to ensure the package can be consumed by the sample app.

## 1.0.40

- Fixed safely unwrap parentVC in webView creation block


## 1.0.39

- Added automatic retry mechanism for non-success status codes (non-2xx responses)

## 1.0.38

- Hide the standalone overlay `UIWindow` while the mini-app is in floating (corner) mode so touches reach the host; show it again on maximize.

## 1.0.37

- Standalone mini-app opened from another mini-app is hosted in a separate transparent `UIWindow` (`windowLevel` above the host) so dismissing the launching app no longer tears down the nested app; teardown runs on `AttachmentController.didDismiss`, and the previous key window is restored.
- `WindowHostView.eventView` for that flow uses the overlay window so keyboard and layout track the correct hierarchy; scene/key resolution aligns with `NativeWindowHostView`-style behavior.
- Short fade-in when presenting standalone as a dialog (`isDialog`).

## 1.0.36

- Add `getMiniAppByWebView` method to MiniAppService
- Update IMiniApp protocol: add force parameter to reloadPage
- Update IMiniApp protocol: add clearCache parameter to requestDismiss

## 1.0.35

- Keep `Window1` alive for standalone `present` and forward keyboard layout to the mini-app (`standaloneModalLayoutTarget` + associated object on the modal nav controller).
- WebView: add keyboard height to `scrollInset`, scroll focused input above keyboard (`scrollIntoView` + native offset); drop `scrollView` offset locking that broke scrolling.
- Fallback keyboard height from `keyboardWillChangeFrame` when `layout.inputHeight` is missing.
- Cancel button dismisses the keyboard when it looks open.
- Version string in UA → `1.0.35`.
