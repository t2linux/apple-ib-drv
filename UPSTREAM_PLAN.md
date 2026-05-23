Upstream Plan for apple-ib-drv
==============================

Objective
---------

Prepare the driver for a realistic Linux mainline upstream proposal,
with a focus on technical quality, maintainability, and submission process.

Current Status (Summary)
------------------------

- Builds on current Arch Linux.
- Maintained on the official project branch `mbp15`.
- Upstream integration debt existed: version-based compatibility shims, local
  `hid-ids.h` copy, missing process artifacts (Kconfig/MAINTAINERS/ABI docs),
  and checkpatch findings.

Execution Status in This Repository
-----------------------------------

- Stage 1 was partially executed in this repository:
  - Removed the large duplicated local `hid-ids.h`.
  - Removed `#ifdef UPSTREAM` and `LINUX_VERSION_CODE` branches from
    `apple-ibridge.c`.
  - Kept a minimal local USB ID set in `apple-ibridge.h` to preserve buildability
    while keeping the patch series aligned with the official branch workflow.
- Pending for actual mainline integration:
  - When integrating under `drivers/hid/`, migrate those minimal IDs to
    `drivers/hid/hid-ids.h`.
- Stage 2 was executed in this tree:
  - Fixed style warnings/checks in `apple-touchbar.c` (casts, logical
    continuations, alignment, and unnecessary parentheses).
  - Hardened sysfs writes (`idle_timeout`, `dim_timeout`, `fnmode`) with
    `spin_lock_irqsave` to avoid races with the worker.
  - Replaced `kzalloc(sizeof(*obj))` with `kcalloc(1, sizeof(*obj), ...)`
    to satisfy checkpatch preference.
  - Current `checkpatch --strict` status: 0 ERROR, 0 WARNING. Two CamelCase
    CHECK items remain for USB fields (`bConfigurationValue`,
    `bInterfaceNumber`) that come from official kernel USB struct names.
- Stage 3 was applied in this tree (submission package preparation):
  - Added `MAINTAINERS` (local template to be migrated into kernel tree).
  - Added sysfs ABI docs in
    `Documentation/ABI/testing/sysfs-driver-hid-apple-touchbar`.
  - Added functional documentation in `Documentation/hid/apple-touchbar.rst`.
  - Added submission templates in `docs/upstream/COVER_LETTER_v1.txt` and
    `docs/upstream/SUBMISSION_CHECKLIST.md`.
  - Remaining work outside this repo: generate and send the real series from
    the official project branch state rebased onto `linux-next`/HID tree using
    `get_maintainer.pl` and
    `git send-email`.

Three-Stage Strategy
--------------------

1) Architecture cleanup and kernel tree integration
2) Style/API cleanup and technical hardening
3) Upstream submission package (patch series + documentation + testing)

Each stage includes scope, tasks, acceptance criteria, and deliverables.

------------------------------------------------------------
Stage 1: Architecture Cleanup and Base Integration
------------------------------------------------------------

Scope
-----

Remove compatibility artifacts and prepare the code to live under
`drivers/hid/` without historical compatibility conditionals.

Tasks
-----

1. Remove duplicated headers and non-upstream local references.
- Remove local `hid-ids.h` from the driver build path.
- Use official kernel headers (`linux/hid.h`, `linux/usb.h`, etc.).
- If any VID/PID is missing in the target kernel tree, prepare a separate
  patch adding it in the correct upstream location (do not keep a local copy).

2. Remove multi-version compatibility code not appropriate for mainline.
- Remove `#if LINUX_VERSION_CODE ...` blocks.
- Remove `#ifdef UPSTREAM` and alternate include paths.
- Use API signatures appropriate for the target baseline.

3. Integrate build with HID subsystem Kconfig/Makefile.
- Add Kconfig entry (description, dependencies, clear help text).
- Add objects to subsystem Makefile (`obj-$(CONFIG_...) += ...`).
- Keep the repository Makefile as an optional local tool, separate from
  upstream integration path.

4. Review ownership and device model.
- Review global touchbar singleton usage and migrate to per-device data if
  needed.
- Validate probe/remove and partial-failure paths to avoid stale state.

Acceptance Criteria
-------------------

- No `LINUX_VERSION_CODE` usage in code intended for submission.
- No mirrored local `hid-ids.h` and no private-header hacks.
- Driver builds in a clean kernel tree with its Kconfig option.
- Probe/remove/suspend-resume paths reviewed without warnings or leaks.

Deliverables
------------

- Patch 1-N: architecture refactor + subsystem Kconfig/Makefile integration.
- Technical rationale notes (for example, why singleton was kept or removed).

Suggested Commands
------------------

```bash
# In a kernel tree (ideally linux-next or HID maintainer tree)
make olddefconfig
make M=drivers/hid W=1
```

------------------------------------------------------------
Stage 2: Style, API, Quality, and Robustness
------------------------------------------------------------

Scope
-----

Align driver code with kernel style expectations and remove obvious
checkpatch debt, while also ensuring PM/input robustness.

Tasks
-----

1. Resolve checkpatch findings (ERROR/WARNING/relevant CHECK items).
- Fix hard errors first (for example, missing sentinels in ID arrays).
- Adjust formatting, alignment, and casts.
- Address helper preference warnings (`kzalloc_obj`, etc.) where applicable.

2. Review touchbar sysfs ABI.
- Confirm `fnmode`, `dim_timeout`, and `idle_timeout` naming and semantics are
  stable.
- Define exact behavior for ranges, defaults, and special values.
- Ensure lock consistency and side effects under concurrent writes.

3. Review PM and autoresume/autopm behavior.
- Validate suspend, freeze, and reset_resume behavior.
- Confirm clean T1/T2 separation in behavior paths.
- Avoid redundant power toggles where unnecessary.

4. Verify expected functional behavior.
- Stable F1-F12 translation and Fn handling.
- Idle/dim/off policy consistent with macOS-like behavior target.
- No regressions in event behavior (dummy wake events and key repeat).

Acceptance Criteria
-------------------

- `checkpatch.pl --strict` with no ERROR and ideally no WARNING.
- Clean `W=1` build.
- PM paths tested on target hardware with no hangs or inconsistent states.
- Stable and documented sysfs ABI.

Deliverables
------------

- Patch N+1..M: style/API cleanup and robustness updates.
- Test evidence (summarized `dmesg` logs and executed test cases).

Suggested Commands
------------------

```bash
scripts/checkpatch.pl --strict 0001-*.patch
make W=1
# Run PM and input tests on real hardware
```

------------------------------------------------------------
Stage 3: Submission Package and Upstream Process
------------------------------------------------------------

Scope
-----

Prepare and send a patch series that is acceptable to HID and related
subsystem reviewers.

Tasks
-----

1. Minimum upstream documentation.
- Add `MAINTAINERS` entry with responsible maintainers and lists.
- Document sysfs ABI under `Documentation/ABI/testing/...`.
- Add user/developer docs under `Documentation/hid/...` if useful.

2. Keep patch series clean and topic-separated.
- Recommended split:
  - 0001: HID: apple-ibridge: base architecture and integration
  - 0002: HID: apple-touchbar: mode/brightness/idle support
  - 0003: HID: apple-touchbar: ABI docs + MAINTAINERS
  - 0004+: incremental improvements (if needed)
- Every commit should clearly state problem, solution, impact, and risks.

3. Test coverage and reporting.
- Minimum matrix:
  - T1: boot, suspend/resume, fnmode, idle/dim/off.
  - T2: detection and non-regression behavior.
  - Desktop environments: GNOME/KDE (at least primary F-key mapping).
- Include `Tested-by` tags where possible.

4. Submission and review cycle.
- Generate patches with `git format-patch`.
- Send with `git send-email` to proper maintainers/lists
  (`scripts/get_maintainer.pl`).
- Respond with v2/v3 while maintaining clear changelog entries.

Acceptance Criteria
-------------------

- Series sent to correct lists with maintainers copied.
- No structural rejections on style/process/architecture basics.
- Reviewer feedback focused on incremental improvements, not baseline blockers.

Deliverables
------------

- v1 patch series.
- Cover letter with technical summary and scope.
- Follow-up plan for v2.

Suggested Commands
------------------

```bash
scripts/get_maintainer.pl -f drivers/hid/<file>.c
git format-patch -N --cover-letter -o outgoing/
git send-email outgoing/*.patch
```

Suggested Execution Timeline (4-6 weeks)
----------------------------------------

Week 1-2
- Complete Stage 1 (architecture and base integration).

Week 3-4
- Complete Stage 2 (style/API/technical validation).

Week 5
- Complete upstream docs, MAINTAINERS, and prepare v1 series.

Week 6
- Send, collect feedback, and start v2.

Main Risks
----------

- Behavior differences between T1/T2 under PM on real hardware.
- Rejection due to too much scope in a single series (split is recommended).
- Unstable or poorly defined sysfs ABI.

Mitigations
-----------

- Send a minimal functional base first, then incremental improvements.
- Keep commits small and technically well justified.
- Attach test evidence by model/scenario.

Quick Readiness Checklist
-------------------------

- [ ] No `LINUX_VERSION_CODE` or `#ifdef UPSTREAM` in code intended for submission.
- [ ] No duplicated kernel headers in the repo.
- [ ] Subsystem Kconfig/Makefile integration ready.
- [ ] checkpatch strict with no errors.
- [ ] Clean `W=1` build.
- [ ] PM validated (suspend/resume/reset_resume).
- [ ] sysfs ABI documented.
- [ ] MAINTAINERS updated.
- [ ] Patch series + cover letter prepared.
