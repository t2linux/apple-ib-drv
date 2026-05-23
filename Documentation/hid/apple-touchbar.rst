====================
Apple Touch Bar HID
====================

Overview
========

This driver pair provides Apple iBridge support and Touch Bar handling for
MacBook Pro models that expose Touch Bar functionality through HID interfaces.

The implementation is split into:

- apple-ibridge: creates virtual HID children per top-level collection.
- apple-touchbar: controls mode, display brightness state, idle/dim policy,
  and function-key translation.

Touch Bar behavior model
========================

The touch bar driver supports:

- Touch bar mode selection (escape only, function row, special row, off).
- Display state transitions (on, dim, off).
- Runtime adaptation based on keyboard, touchpad and touch bar activity.
- Fn key dependent switching between function and special rows.

Sysfs interface
===============

The mode HID device exposes writable attributes documented in:

- Documentation/ABI/testing/sysfs-driver-hid-apple-touchbar

Suspend and resume
==================

For T1-based systems, the driver restores a consistent mode/display state on
resume and explicitly handles suspend transitions to avoid stale internal state.

For T2-based systems, platform behavior differs and the driver avoids applying
T1-specific suspend handling.

Testing recommendations
=======================

Minimum validation before submission:

- Boot and module load without warnings.
- Fn switching semantics across all fnmode values.
- idle_timeout and dim_timeout transitions.
- suspend/resume and reset_resume behavior on T1 hardware.
- no regressions in input event translation for media and brightness keys.
