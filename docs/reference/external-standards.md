# External Standards

- Category: `reference`
- Scope: `repository`

## Documentation hierarchy

This repo follows a category-first hierarchy inspired by Diataxis:

- keep tutorials, how-to material, reference, and explanation separate when the set grows
- use landing pages for each section
- split long lists into smaller grouped sections

For this repository, the adapted categories are `product`, `design`, `engineering`, `architecture`, `api`, and `reference`.

## API docs

For Swift packages and Apple-platform code, the preferred API-doc path is DocC:

- keep an overview page
- add focused articles for feature-level contracts
- connect docs to symbols and types as the surface becomes more explicit

For larger multi-system docs portals later, these npm-distributed options were identified through MCP fetches:

- `docusaurus-plugin-openapi-docs`
- `redocusaurus`

Those are future portal options, not current repository dependencies.

## Traceability rule

A large documentation tree stays navigable only if each important document can answer:

1. what category it belongs to
2. what scope it covers
3. what code it describes
4. what tests verify it
5. what API docs mirror it
