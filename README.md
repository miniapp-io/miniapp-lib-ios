# MiniAppX

## Project Introduction

This project is a lightweight mini program engine solution for iOS, containing two core libraries:

- The core mini program runtime library, responsible for pluginization, authentication, Bot, MiniApp, and other business capabilities.

---

## Architecture Description

```
┌─────────────────────────────┐
│         MiniAppX            │
│  ────────────────────────   │
│  Plugin management,         │
│  Authentication, Bot,       │
│  MiniApp, business logic,   │
│  bridging, extension points │
└─────────────┬───────────────┘
              │
┌─────────────▼───────────────┐
│         MiniAppUIKit        │
│  ────────────────────────   │
│  High-performance UI        │
│  components, animation,     │
│  asynchronous rendering,    │
│  basic utilities            │
└─────────────────────────────┘
```

---

## Main Features

### MiniAppX
- Mini program runtime and lifecycle management
- Plugin architecture with dynamic extension support
- Bot/robot capabilities
- Authentication and security
- MiniApp container and bridging
- Rich business extension points

---

## Integration Methods

### 1. CocoaPods Integration

```ruby
  pod 'MiniAppX'
  pod 'MiniAppUIKit'
```


## Applicable Scenarios
- iOS implementation of mini program platforms such as Telegram/WeChat/DingTalk
- Bot/robot platforms
- Pluginized, dynamically extensible apps
- Business modules requiring high-performance UI components

---

## License

MIT
