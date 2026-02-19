---
name: figma
description: "Build or modify UI based on Figma designs by using the official Figma remote MCP server to inspect frames, styles, and components, then generate code that matches the project's styling system (SCSS or Tailwind CSS). Use when the user asks to implement UI from Figma or update UI to match a Figma file/node."
---

# Figma UI Implementation

## Quick start

- Ask for the Figma file link with `node-id` (or confirm the provided one).
- Use the Figma remote MCP server to read the target frames, components, and styles.
- Detect the project's styling system (SCSS or Tailwind CSS) from the repo before writing styles.
- Implement UI code that matches layout, typography, spacing, colors, and component behavior.

## Workflow

### 1) Confirm inputs

- Require a Figma link that includes `node-id`.
- Ask for the target page/component in the repo if multiple candidates exist.
- Ask for any product constraints (breakpoints, design tokens, preferred components).

### 2) Read Figma via MCP

- Use the official Figma remote MCP server for all design extraction.
- Read the selected node and its immediate children.
- Capture the following from Figma:
  - Layout: frame sizes, constraints, auto layout settings, spacing
  - Typography: font families, weights, sizes, line-heights, letter-spacing
  - Colors: fills, strokes, opacity
  - Effects: shadows, blur
  - Components: variants, states, icons

### 3) Detect styling system

- Identify Tailwind usage by looking for `tailwind.config.*`, `postcss.config.*`, and existing utility-class usage.
- Identify SCSS usage by looking for `.scss` files, `sass`/`scss` dependencies, and existing import patterns.
- If both are present or unclear, ask the user which one to use.

### 4) Implement UI

- Match the repo's component structure, naming, and file placement.
- Use existing design tokens or variables if present; do not invent new ones without confirmation.
- If Tailwind is used:
  - Prefer utility classes over custom CSS.
  - Use existing Tailwind config tokens (colors, spacing, typography) where possible.
- If SCSS is used:
  - Add styles to the existing SCSS structure (modules, BEM, or global files as applicable).
  - Keep selectors consistent with current conventions.

### 5) Validate against Figma

- Compare spacing, alignment, typography, and color values against Figma.
- Note any gaps or assumptions explicitly and ask for confirmation.

## Output expectations

- Provide code changes that implement or update the UI to match Figma.
- Include only the styling system the project uses (SCSS or Tailwind).
- Call out any missing inputs or ambiguous design elements.
