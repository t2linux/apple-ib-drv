Stage 3 Submission Checklist
============================

Preconditions
-------------

- Build passes: make W=1
- Smoke test passes: make test
- checkpatch strict has no errors/warnings in target patches
- Runtime tests captured (T1 and, if available, T2 non-regression)

Recommended patch split
-----------------------

1. HID: apple-ibridge: add iBridge split driver
2. HID: apple-touchbar: add mode/display/timeout/Fn handling
3. HID: apple-touchbar: add ABI docs and maintainer entry

Generate patch series
---------------------

```bash
# From a clean state of the official project branch (mbp15),
# rebased onto linux-next or HID maintainer tree
scripts/get_maintainer.pl -f drivers/hid/apple-ibridge.c
scripts/get_maintainer.pl -f drivers/hid/apple-touchbar.c

git format-patch -3 --cover-letter -o outgoing/
```

Send patches
------------

```bash
git send-email outgoing/*.patch
```

Review cycle
------------

- Reply inline to review comments.
- Send v2/v3 with changelog under the cover letter and each patch.
- Keep subject prefixes stable to preserve thread continuity.

Artifacts in this repository
----------------------------

- MAINTAINERS
- Documentation/ABI/testing/sysfs-driver-hid-apple-touchbar
- Documentation/hid/apple-touchbar.rst
- docs/upstream/COVER_LETTER_v1.txt
