---
title: "Notifications API"
summary: "Read authorization and explicitly schedule macOS local notifications asynchronously."
category: "Reference"
order: 20
keywords: ["notifications", "API", "lifecycle"]
symbols: ["NotificationsSupported", "NotificationOutcome", "NotificationRequest.ReadAuthorization", "NotificationRequest.RequestAuthorization", "NotificationRequest.Schedule", "NotificationRequest.IsComplete", "NotificationRequest.Outcome", "NotificationRequest.ErrorCode", "NotificationRequest.ErrorMessage", "NotificationRequest.AuthorizationStatus", "NotificationRequest.CancellationRequested", "NotificationRequest.Cancel", "CancelPendingNotification", "RemoveDeliveredNotification", "ConfigureForegroundNotifications"]
related: ["index.md", "getting-started.md", "typed-api.md"]
---

# Notifications API

Import the `notifications` package. Constructors below use the class name; invoke them with `New`. Listed members are public client APIs; native declarations and trampoline helpers are implementation details.

## Public surface

| Symbol | Contract |
| --- | --- |
| `NotificationsSupported() As Boolean` | Checks native OS, app-bundle, and desktop context. |
| `NotificationOutcome` | Enum: Pending, Succeeded, Denied, Failed. |
| `NotificationRequest.ReadAuthorization() As NotificationRequest` | Shared read-only asynchronous authorization query. |
| `NotificationRequest.RequestAuthorization(alerts As Boolean = True, sounds As Boolean = True, badges As Boolean = False) As NotificationRequest` | Shared explicit permission request; may show the native prompt. |
| `NotificationRequest.Schedule(identifier As String, title As String, body As String, delaySeconds As Double = 1.0, sound As Boolean = False) As NotificationRequest` | Shared one-shot delayed schedule. Reusing an identifier replaces a pending request. |
| `NotificationRequest.IsComplete As Boolean` | Read-only atomic publication of callback completion. |
| `NotificationRequest.Outcome As NotificationOutcome` | Pending before completion, otherwise the completed outcome. |
| `NotificationRequest.ErrorCode As Integer` | Native code only for a completed Failed outcome; zero otherwise. |
| `NotificationRequest.ErrorMessage As String` | Empty while pending; completed diagnostic afterward. |
| `NotificationRequest.AuthorizationStatus As Integer` | For a successful authorization read: 0 not determined, 1 denied, 2 authorized, 3 provisional. Otherwise -1. |
| `NotificationRequest.CancellationRequested As Boolean` | Whether cancellation was requested on this schedule object. |
| `NotificationRequest.Cancel()` | Cancels an accepted schedule now or after an in-flight add is accepted. |
| `CancelPendingNotification(identifier As String)` | Removes one pending request by identifier. |
| `RemoveDeliveredNotification(identifier As String)` | Removes one delivered notification by identifier. |
| `ConfigureForegroundNotifications(alerts As Boolean, sounds As Boolean = False, badges As Boolean = False)` | Opt-in foreground presentation; all false restores the default. Refuses to replace another notification delegate. |

## Ownership and timing

Retain the returned request and poll IsComplete from your app timer without blocking the UI. Then read Outcome, ErrorCode/ErrorMessage, and AuthorizationStatus where applicable. Requests self-retain until callback completion. Request permission explicitly before scheduling. Successful scheduling means accepted for queueing, not guaranteed display: permission, Focus, and system policy still apply.

## Errors and result interpretation

Identifiers and notification text are validated. Schedule requires a nonblank title and a finite delay of 1 second through 1 year. RequestAuthorization rejects all options false. Cancel applies only to schedule requests, and cancellation cannot retract already delivered notifications. Identifiers are shared with later requests: do not cancel an old object after reusing its identifier.

Handle initiation and completion separately. Starting a request can throw
`UnsupportedOperationException` for an unsupported context or
`InvalidArgumentException` for invalid arguments, before returning a request.
Catch those exceptions at the call site. Once a request is returned, retain it,
poll `IsComplete`, and branch on `Outcome`; native callback failures are reported
as `Failed` with `ErrorCode` and `ErrorMessage`.

A successful `ReadAuthorization()` means the settings query completed, not that
permission was granted. In particular, `Outcome = Succeeded` together with
`AuthorizationStatus = 1` means notifications are denied. In contrast,
`RequestAuthorization()` reports a declined permission request as `Outcome = Denied`
with `ErrorCode = 0` and an empty `ErrorMessage`. Its `AuthorizationStatus` remains
-1 because that property is only populated by a successful authorization read.
Do not treat a zero error code or an empty message as proof of permission or
successful scheduling; they also occur while a request is pending. A failure to
decode a native completion can also produce `Failed` with a zero error code.

## Platform behavior

Requires macOS 11 or newer, an identified .app bundle, and a desktop session. Bare CLI, Windows, and Linux operations are unsupported and throw rather than using shell commands or fallback toasts. Foreground configuration requires the main thread.

See the [complete usage example](getting-started.md) and the [package overview](index.md).


[Full typed API: properties, parameters, defaults, and returns](typed-api.md)
