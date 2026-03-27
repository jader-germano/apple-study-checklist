# Figma Prototype Brief

## Status

This repository is ready for a Figma-driven implementation workflow, but the Figma MCP server is not exposed in the current Codex session.

That means this document is the handoff brief for the next design session, not the output of a live Figma extraction.

## Required Figma workflow

The intended workflow follows the local `figma-implement-design` skill:

1. select a frame or provide a Figma URL
2. fetch design context
3. capture a screenshot
4. map the result into project conventions
5. validate code against the design source

## Screens to prototype

### 1. Checklist workspace

- Week list
- Week summary
- Daily checklist cards
- References, glossary, and study guide blocks

### 2. Vault workspace

- Vault source controls
- Markdown file list
- Editor and preview surface
- Save and error feedback states

### 3. Cross-platform adaptations

- iPad regular-width layout
- iPhone compact navigation flow
- visionOS concept only after the shared app flows are stable

## Components to design

- Navigation shell
- Week row
- Week detail header
- Daily task card
- Markdown file row
- Editor header
- Save feedback banner
- Appearance selector

## Design constraints

- Respect the current SwiftUI-first architecture
- Reuse Apple system patterns where possible
- Avoid creating a second product language for the vault
- Keep the app local-first even when MCP-backed content arrives later
