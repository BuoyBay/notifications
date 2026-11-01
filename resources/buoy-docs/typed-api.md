---
title: "notifications typed API"
summary: "Source-derived public signatures, properties, parameters, defaults, and return values."
category: "Reference"
order: 21
types: ["NotificationOutcome", "NotificationRequest"]
dependencies: []
symbols: ["NotificationOutcome", "NotificationRequest"]
related: ["api.md", "getting-started.md", "index.md"]
---

# notifications typed API

Generated from the package source declarations. Platform guards are shown where present; inherited members are documented on the base type. See the [API contracts](api.md) for behavior and limitations.

## NotificationOutcome

`Public Enum NotificationOutcome As Integer`

### Values

| Name | Type | Value / Default | Description |
| --- | --- | --- | --- |
| `Pending` | `NotificationOutcome` | `0` | — |
| `Succeeded` | `NotificationOutcome` | `1` | — |
| `Denied` | `NotificationOutcome` | `2` | — |
| `Failed` | `NotificationOutcome` | `3` | — |

## Notifications functions

### NotificationsSupported

`Public Function NotificationsSupported() As Boolean`

No parameters.

#### Returns

| Type |
| --- |
| `Boolean` |

### ConfigureForegroundNotifications

`Public Sub ConfigureForegroundNotifications(alerts As Boolean, sounds As Boolean = False, badges As Boolean = False)`

Opt-in foreground presentation. Refuses to replace a delegate installed by another integration.

#### Parameters

| Name | Type | Passing | Default |
| --- | --- | --- | --- |
| `alerts` | `Boolean` | `ByVal` | Required |
| `sounds` | `Boolean` | `ByVal` | `False` |
| `badges` | `Boolean` | `ByVal` | `False` |

Returns: no value.

### CancelPendingNotification

`Public Sub CancelPendingNotification(identifier As String)`

#### Parameters

| Name | Type | Passing | Default |
| --- | --- | --- | --- |
| `identifier` | `String` | `ByVal` | Required |

Returns: no value.

### RemoveDeliveredNotification

`Public Sub RemoveDeliveredNotification(identifier As String)`

#### Parameters

| Name | Type | Passing | Default |
| --- | --- | --- | --- |
| `identifier` | `String` | `ByVal` | Required |

Returns: no value.

## NotificationRequest

`Public Class NotificationRequest`

A pollable asynchronous result. Authorization and delivery are never requested implicitly.

### Properties

| Name | Type | Read-Only | Shared | Default | Description |
| --- | --- | --- | --- | --- | --- |
| `IsComplete` | `Boolean` | Yes | No | — | — |
| `Outcome` | `NotificationOutcome` | Yes | No | — | — |
| `ErrorCode` | `Integer` | Yes | No | — | — |
| `ErrorMessage` | `String` | Yes | No | — | — |
| `AuthorizationStatus` | `Integer` | Yes | No | — | Apple UNAuthorizationStatus: 0 not determined, 1 denied, 2 authorized, 3 provisional. |
| `CancellationRequested` | `Boolean` | Yes | No | — | — |

### ReadAuthorization

`Public Shared Function ReadAuthorization() As NotificationRequest`

Does not prompt. Poll the returned request before reading AuthorizationStatus.

No parameters.

#### Returns

| Type |
| --- |
| `NotificationRequest` |

### RequestAuthorization

`Public Shared Function RequestAuthorization(alerts As Boolean = True, sounds As Boolean = True, badges As Boolean = False) As NotificationRequest`

Explicit opt-in: may display the system permission prompt.

#### Parameters

| Name | Type | Passing | Default |
| --- | --- | --- | --- |
| `alerts` | `Boolean` | `ByVal` | `True` |
| `sounds` | `Boolean` | `ByVal` | `True` |
| `badges` | `Boolean` | `ByVal` | `False` |

#### Returns

| Type |
| --- |
| `NotificationRequest` |

### Schedule

`Public Shared Function Schedule(identifier As String, title As String, body As String, delaySeconds As Double = 1.0, sound As Boolean = False) As NotificationRequest`

Successful completion means accepted for scheduling, not that Focus/OS policy displayed it.

#### Parameters

| Name | Type | Passing | Default |
| --- | --- | --- | --- |
| `identifier` | `String` | `ByVal` | Required |
| `title` | `String` | `ByVal` | Required |
| `body` | `String` | `ByVal` | Required |
| `delaySeconds` | `Double` | `ByVal` | `1.0` |
| `sound` | `Boolean` | `ByVal` | `False` |

#### Returns

| Type |
| --- |
| `NotificationRequest` |

### Cancel

`Public Sub Cancel()`

Cancel scheduling now or as soon as an in-flight add is accepted. Authorization prompts cannot be cancelled here.

No parameters.

Returns: no value.

### AcceptNativeCompletion

`Public Shared Sub AcceptNativeCompletion(context As Ptr, outcome As Int32, code As Integer, message As Ptr)`

Availability: `#If TargetMac Then`

#### Parameters

| Name | Type | Passing | Default |
| --- | --- | --- | --- |
| `context` | `Ptr` | `ByVal` | Required |
| `outcome` | `Int32` | `ByVal` | Required |
| `code` | `Integer` | `ByVal` | Required |
| `message` | `Ptr` | `ByVal` | Required |

Returns: no value.
