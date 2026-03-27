# System UI and UX Spec

## Navigation

- Primary shell:
  - tab-based separation between `Checklist` and `Vault`
- Checklist:
  - split navigation on desktop and large screens
  - compact push navigation later on smaller devices
- Vault:
  - document list on the leading side
  - viewer or editor in the detail area

## Visual system

- Use Apple system typography as the baseline
- Keep hierarchy strong through spacing and sectioning before adding decoration
- Preserve a technical tool aesthetic instead of a marketing UI aesthetic

## States

### Checklist

- empty week selection
- normal browsing
- progress update
- week reset

### Vault

- no workspace selected
- workspace loaded
- file selected
- save success
- save failure

## Theme model

- `automatic`
- `light`
- `dark`

The theme selection should live in app state and affect both checklist and vault surfaces.

## Platform adaptation rules

### macOS

- full split view is acceptable
- command-centric editing workflows are acceptable

### iOS

- compact navigation must replace desktop assumptions
- file picking must not depend on `NSOpenPanel`
- toolbar density must be reduced

### visionOS

- do not ship a spatial experience just to mirror the desktop layout
- only add a dedicated visionOS surface when the interaction model adds value

## Design validation checklist

- Can the user tell which study context is active?
- Can the user tell whether the current workspace is editable?
- Can the user tell whether a file save succeeded or failed?
- Are reading and editing both viable in dark mode?
- Does the compact layout preserve the product model without cloning the desktop split view?
