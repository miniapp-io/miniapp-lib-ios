# Changelog

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
