# Bootstrap 6.10.2

## Scope

This repo tracked an exploratory Linux/Python 3.13 UIBCDF line for
`PySide6_Essentials` version `6.10.2`.

It is no longer the preferred first release-candidate line.
It remains valuable as the branch where we learned the correct packaging
architecture and the real source-build constraints for coexistence with the
native `PySide6` stack.

## What 6.10.2 Already Taught Us

The `6.10.2` exploration established that the right long-term architecture is:

- sibling `*-uibcdf` repos
- suffixed Python namespaces:
  - `shiboken6_uibcdf`
  - `PySide6_uibcdf`
- real source-builds when coexistence matters
- explicit build-toolchain handling for:
  - LLVM / Clang discovery
  - OpenGL headers
  - generated wrapper/runtime layout

It also validated that the work should not live only in `molsysviewer`.

## Why 6.10.2 Is No Longer The First Line To Close

The exploratory build moved far enough to show a different class of blocker:

- not packaging
- not namespace split
- not basic source-build viability

Instead, the remaining failures started to reflect source/API drift between:

- `*_uibcdf 6.10.2`
- and `qt6-main 6.9.2`

Concrete examples already exposed on this branch include:

- `QRangeModel` being present in the `6.10.2` source assumptions but gated to
  Qt 6.10+
- `QDirListing` wrappers generated against signatures that do not match the
  `qt6-main 6.9.2` headers

That means this line is still useful, but no longer the cleanest first target.

## Preferred Next Line

The first line to close cleanly should now be:

- `shiboken6-uibcdf 6.9.2`
- `pyside6-essentials-uibcdf 6.9.2`
- `pyside6-addons-uibcdf 6.9.2`
- against `qt6-main 6.9.2`

This `6.10.2` branch should therefore be read as:

- an exploratory branch
- a source of build-system / namespace knowledge
- not the preferred first release-candidate line

## What Must Be Reused In 6.9.2

Do not lose the following lessons when reopening `6.9.2`:

- use suffixed Python namespaces from the start
- do not rely on pure repackaging when coexistence matters
- propagate LLVM / Clang discovery explicitly
- ensure shiboken wrapper invocations keep the required runtime/build env
- keep generated wrapper source lists aligned with the actual Qt base version

## Expected Upstream Source

The upstream code should be taken from:

- `/home/diego/repos@others/pyside-setup`

Relevant upstream subtree for this repo:

- `/home/diego/repos@others/pyside-setup/sources/pyside6`

## Historical 6.9.2 Bootstrap Assets

The earlier `6.9.2` boundary/bootstrap assets remain useful as historical
scaffolding for the clean aligned line.

They should be treated as:

- evidence for the `6.9.2` line
- not as justification for forcing `6.10.2` to fit `qt6-main 6.9.2`
