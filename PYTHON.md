# Python policy for notifications

Python files are ignored by default. New production tooling belongs in Buoy or BuoyScript.
Generated/local validation helpers stay on the maintainer machine and are not public source.

The following exact files remain temporary production compatibility exceptions:

| File | Required capability |
| --- | --- |
| `build_native.py` | Only current source builder for the macOS UserNotifications Objective-C bridge and its receipt. |

An exception may be removed after its native replacement passes the corresponding build or runtime checks.
Review additions file by file; directory-wide and wildcard Python exceptions are not allowed.
