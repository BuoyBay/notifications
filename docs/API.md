# notifications · 0.1.0

Explicit macOS local notification integration using UserNotifications. `Import
notifications`. Importing, checking support and reading authorization never ask
permission or schedule a notification. A macOS 11+ identified `.app` bundle and a
desktop session are required; a bare CLI returns unsupported without invoking
`UNUserNotificationCenter` in an invalid context.

| API | Behavior |
| --- | --- |
| `NotificationsSupported()` | Checks native OS/app-bundle context. |
| `NotificationRequest.ReadAuthorization()` | Asynchronously reads the current authorization status without prompting. |
| `NotificationRequest.RequestAuthorization(alerts = True, sounds = True, badges = False)` | **Explicit** permission request; may show the OS dialog. |
| `NotificationRequest.Schedule(identifier, title, body, delaySeconds = 1.0, sound = False)` | Explicit single delayed notification. Same identifier replaces that app's pending request. Delay is 1 second through 1 year. |
| `request.Cancel()` | For scheduled requests: cancels now or immediately after an in-flight add is accepted. Does not cancel authorization dialogs. |
| `CancelPendingNotification(identifier)` | Remove a specific pending request. |
| `RemoveDeliveredNotification(identifier)` | Remove a specific delivered notification. |
| `ConfigureForegroundNotifications(alerts, sounds = False, badges = False)` | Opt into foreground banners/list, sound or badges. All false restores the default. Requires main thread and refuses to replace another component's notification delegate. |

Retain/poll the returned request. `IsComplete` publishes completion; read `Outcome`
(`Pending`, `Succeeded`, `Denied`, `Failed`), `ErrorCode` and `ErrorMessage` after
it completes. Authorization reads also expose `AuthorizationStatus` (Apple values:
0 not determined, 1 denied, 2 authorized, 3 provisional; -1 unavailable). A successful
authorization request means granted; a successful schedule means accepted for
queueing, **not** guaranteed display. User permission, Focus and OS presentation
policy remain in control. Request authorization explicitly before scheduling.

The operation self-retains until its native callback, so dropping a caller's
reference does not leave a dangling C context. Completion errors and Objective-C
exceptions become explicit results. Cancel uses atomic publication to cover the
race between an in-flight add callback and the caller requesting cancellation.
Cancellation cannot retract a notification the system already delivered; use the
separate delivered-removal API when appropriate. An accepted cancellation is a
request to the OS, not a delivery receipt.

No remote push/APNs setup, action buttons, click-response delegate, repeating
calendar triggers, or silent authorization escalation is included. Foreground
presentation is off unless explicitly configured. All unsupported platforms throw
`UnsupportedOperationException`; there is no shell-command/toast fallback.
`AcceptNativeCompletion` is an internal trampoline entry, not a client API.

## Native bridge and build

Buoy does not yet expose Objective-C block completion handlers directly. The
small ARC Objective-C source at `native/bridge.m` adapts Apple's blocks into a
pollable C callback. Rebuild on macOS with `python3 build_native.py`
before sealing. The checked runtime dylib is universal arm64/x86_64, macOS 11+,
with `@rpath/libbuoy_notifications.dylib` install name. Buoy copies it into app
Frameworks automatically; no private Apple APIs or external notification tools
are used. Rebuild for your distribution/signing workflow rather than treating the
checked artifact as a code-signing identity.

## Verification


Maintainers run the private validation suite before release. See the repository README for public build instructions.

