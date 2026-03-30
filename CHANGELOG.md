# Changelog

## 1.0.40

- Fixed 


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
