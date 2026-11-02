# macOS local notifications — authorize and schedule

Explicit macOS local notification integration using UserNotifications. `Import
notifications`. Importing, checking support and reading authorization never ask
permission or schedule a notification. A macOS 11+ identified `.app` bundle and a
desktop session are required; a bare CLI returns unsupported without invoking
`UNUserNotificationCenter` in an invalid context.

Retain/poll the returned request. `IsComplete` publishes completion; read `Outcome`
(`Pending`, `Succeeded`, `Denied`, `Failed`), `ErrorCode` and `ErrorMessage` after
it completes. Authorization reads also expose `AuthorizationStatus` (Apple values:
0 not determined, 1 denied, 2 authorized, 3 provisional; -1 unavailable). A successful
authorization request means granted; a successful schedule means accepted for
queueing, **not** guaranteed display. User permission, Focus and OS presentation
policy remain in control. Request authorization explicitly before scheduling.

## Install

From a Buoy consumer project with BPM installed:

```sh
bpm add notifications --git https://github.com/BuoyBay/notifications.git --rev refs/heads/main
```

BPM records the resolved commit in its lockfile. Keep that lockfile with the
consumer project for reproducible installs.

## Example

```basic
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

## Platform and scope

Requires a supported macOS identified application bundle and desktop session. Authorization requests and scheduling are explicit; importing the package does neither.

## Build and API reference

Source is in `modules/`, with native/runtime inputs where required. Use the
[package guide](docs/API.md) for backend-specific build prerequisites, ownership
rules and supported targets. Rebuilding a native backend requires that target's
compiler and SDK; sealing an archive alone does not rebuild the backend.

## Local Buoy setup

On your own machine, install Buoy and run:

```sh
buoy ai init --both
```

## Contributing

[Contributing](CONTRIBUTING.md) · [License](LICENSE)
