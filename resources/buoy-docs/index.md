---
title: "Notifications"
summary: "Read authorization and explicitly schedule macOS local notifications asynchronously."
category: "Overview"
order: 0
keywords: ["notifications"]
related: ["getting-started.md", "api.md", "typed-api.md"]
---

# Notifications

NotificationRequest adapts UserNotifications callbacks into pollable requests. Support checks and ReadAuthorization do not prompt or schedule anything. Permission requests, scheduling, cancellation, and foreground presentation are separate explicit actions.

## Platform support

Requires macOS 11 or newer, an identified .app bundle, and a desktop session. Bare CLI, Windows, and Linux operations are unsupported and throw rather than using shell commands or fallback toasts. Foreground configuration requires the main thread.

## Start reading

- [Getting started](getting-started.md) walks through installation and a complete example.
- [API reference](api.md) describes public symbols, state, errors, and ownership.

## Scope

Retain the returned request and poll IsComplete from your app timer without blocking the UI. Then read Outcome, ErrorCode/ErrorMessage, and AuthorizationStatus where applicable. Requests self-retain until callback completion. Request permission explicitly before scheduling. Successful scheduling means accepted for queueing, not guaranteed display: permission, Focus, and system policy still apply.
