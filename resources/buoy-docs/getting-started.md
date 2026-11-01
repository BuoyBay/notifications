---
title: "Notifications getting started"
summary: "Install notifications and use its core API with explicit application ownership."
category: "Guides"
order: 10
keywords: ["notifications", "installation", "example"]
related: ["index.md", "api.md", "typed-api.md"]
---

# Notifications getting started

## Install and import

Copy the sealed `notifications-0.1.0.buipkg` archive into your project `packages/` directory, or install a source/registry dependency named `notifications` using BPM and sync it. Then use `Import notifications`. The archive includes this documentation as package resources.

Use a consuming source filename such as `main.bui`; a local module named exactly like the package shadows its import.

## Complete usage example

The example is compiler-checked as a complete Buoy module. Functions and Subs are intended to be called from the consuming app at the appropriate user action or lifecycle event.

```buoy
Import notifications

Function BeginAuthorizationRead() As NotificationRequest
    If Not NotificationsSupported() Then Return Nil
    Return NotificationRequest.ReadAuthorization()
End Function

Sub InspectCompletedRead(request As NotificationRequest)
    If request = Nil Then Return
    If Not request.IsComplete Then Return
    If request.Outcome = NotificationOutcome.Succeeded Then
        Print request.AuthorizationStatus
    Else
        Print request.ErrorMessage
    End If
End Sub
```

## Integrate with the application

Retain the returned request and poll IsComplete from your app timer without blocking the UI. Then read Outcome, ErrorCode/ErrorMessage, and AuthorizationStatus where applicable. Requests self-retain until callback completion. Request permission explicitly before scheduling. Successful scheduling means accepted for queueing, not guaranteed display: permission, Focus, and system policy still apply.

## Building from source

The package uses a small ARC Objective-C bridge for native completion callbacks. Source builds on macOS must rebuild it using `python3 build_native.py` before sealing. A sealed distribution supplies the runtime library; consumers do not need an Objective-C toolchain simply to import it. Rebuild and sign native artifacts for your distribution rather than treating the checked development binary as your signing identity.

## Handle failures and unsupported targets

Identifiers and notification text are validated. Schedule requires a nonblank title and a finite delay of 1 second through 1 year. RequestAuthorization rejects all options false. Cancel applies only to schedule requests, and cancellation cannot retract already delivered notifications. Identifiers are shared with later requests: do not cancel an old object after reusing its identifier.

Requires macOS 11 or newer, an identified .app bundle, and a desktop session. Bare CLI, Windows, and Linux operations are unsupported and throw rather than using shell commands or fallback toasts. Foreground configuration requires the main thread.

Return to the [overview](index.md) or consult the [API reference](api.md).
