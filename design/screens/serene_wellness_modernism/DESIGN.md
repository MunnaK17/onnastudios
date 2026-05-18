---
name: Serene Wellness Modernism
colors:
  surface: '#fbf9f4'
  surface-dim: '#dbdad5'
  surface-bright: '#fbf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ee'
  surface-container: '#f0eee9'
  surface-container-high: '#eae8e3'
  surface-container-highest: '#e4e2dd'
  on-surface: '#1b1c19'
  on-surface-variant: '#4d4540'
  inverse-surface: '#30312e'
  inverse-on-surface: '#f2f1ec'
  outline: '#7e756f'
  outline-variant: '#cfc4bd'
  surface-tint: '#635d5a'
  primary: '#181512'
  on-primary: '#ffffff'
  primary-container: '#2d2926'
  on-primary-container: '#96908b'
  inverse-primary: '#cdc5c0'
  secondary: '#735a3a'
  on-secondary: '#ffffff'
  secondary-container: '#fddab2'
  on-secondary-container: '#785e3e'
  tertiary: '#320400'
  on-tertiary: '#ffffff'
  tertiary-container: '#501609'
  on-tertiary-container: '#d17a66'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9e1dc'
  primary-fixed-dim: '#cdc5c0'
  on-primary-fixed: '#1e1b18'
  on-primary-fixed-variant: '#4b4642'
  secondary-fixed: '#ffddb6'
  secondary-fixed-dim: '#e2c19b'
  on-secondary-fixed: '#291801'
  on-secondary-fixed-variant: '#594325'
  tertiary-fixed: '#ffdad3'
  tertiary-fixed-dim: '#ffb4a4'
  on-tertiary-fixed: '#3c0701'
  on-tertiary-fixed-variant: '#763223'
  background: '#fbf9f4'
  on-background: '#1b1c19'
  surface-variant: '#e4e2dd'
typography:
  h1:
    fontFamily: Epilogue
    fontSize: 48px
    fontWeight: '500'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  h2:
    fontFamily: Epilogue
    fontSize: 36px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  h3:
    fontFamily: Epilogue
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.0'
    letterSpacing: 0.1em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 64px
  section-padding: 120px
  card-gap: 32px
---

## Brand & Style

The design system is anchored in a philosophy of "breathable luxury." It aims to evoke a sense of immediate calm, mirroring the physical experience of entering a high-end yoga sanctuary. The brand personality is poised, welcoming, and sophisticated, avoiding the cluttered aesthetics of traditional fitness apps in favor of a curated, editorial approach.

The visual style is **Minimalism** infused with **Tactile** warmth. By utilizing a restrained color palette and expansive white space, the system prioritizes clarity and mental ease. Large-scale, high-quality imagery of natural textures and soft lighting serves as a primary visual pillar, ensuring the digital environment feels as grounded and organic as the physical studio.

## Colors

The color strategy for this design system utilizes a foundation of warm neutrals to create a serene environment. The primary palette consists of **Dark Charcoal** for high-contrast typography and **Cream/Off-white** for expansive backgrounds. **Beige** and **Brown** are employed for secondary surfaces and structural elements, providing a soft layering effect.

Accents are used sparingly to maintain sophistication. **Gold** is reserved for premium indicators, subtle borders, or iconography highlights, while **Terracotta** serves as the primary action color, providing a grounded, earthy energy for call-to-action elements.

## Typography

This design system uses a pairing of two sans-serifs to balance editorial style with functional clarity. **Epilogue** is the headline face; its geometric yet expressive nature adds a contemporary, premium edge to the studio's voice. Headlines should be set with tight leading and slight negative letter-spacing to appear as cohesive units of thought.

For all functional and long-form text, **Manrope** provides a highly readable, balanced experience. It maintains a calm, professional tone. A specialized "label-caps" style is used for small metadata, categories, and overlines, adding a rhythmic, organized feel to the information hierarchy.

## Layout & Spacing

The layout philosophy follows a **fixed grid** approach for desktop (12 columns) and a fluid model for mobile devices. The core of this design system is "generous whitespace." Elements are given significant room to breathe, preventing cognitive overload and reinforcing the studio's calm atmosphere.

Spacing follows an 8px rhythmic scale, but section-level vertical padding is intentionally oversized (120px+) to create a distinct sense of "chapters" as the user scrolls. Content should be centered with wide margins to draw the eye inward toward high-quality imagery and key messaging.

## Elevation & Depth

To maintain a minimalist aesthetic while providing visual hierarchy, this design system uses **Ambient Shadows** and **Tonal Layers**. Shadows are never harsh; they are extra-diffused, using a low-opacity charcoal tint (#2D2926 at 4-8% opacity) with a large blur radius to make cards appear to "float" softly above the cream background.

Depth is also achieved through subtle shifts in background color. Primary content sits on the off-white base, while secondary containers or "sticky" elements use the slightly darker beige tone. This "surface-on-surface" technique creates structure without the need for heavy borders.

## Shapes

The shape language is defined by organic, large-scale roundedness. This design system uses 1rem (16px) as the base radius for standard components like input fields and buttons, while larger containers and cards utilize "rounded-xl" (1.5rem / 24px) to create a soft, non-aggressive UI.

Imagery should also follow these rounding rules, though full-bleed hero sections remain sharp-edged to ground the layout. Decorative elements, such as gold or terracotta accents, may occasionally use pill-shaped (rounded-full) geometry to denote interactivity or status.

## Components

**Buttons:** The primary CTA uses the Terracotta color with white text, featuring a subtle hover transition that deepens the hue. Secondary buttons are "ghost" style with a thin Gold or Dark Charcoal border and no fill. All buttons use high horizontal padding to appear elegant and elongated.

**Cards:** Cards are the primary organizational unit. They feature "rounded-xl" corners, the softest ambient shadow, and a subtle 1px border in a slightly darker beige to define their edges against the cream background. Imagery within cards should always fill the top half or the entire background.

**Inputs & Selection:** Text fields use a minimal "bottom-border only" or a very light beige fill. Checkboxes and radio buttons are swapped for elegant "chips" or custom-styled circular toggles that use Gold when active.

**Yoga-Specific Components:**
- **Schedule Strips:** Horizontal list items with generous vertical padding, separated by hair-line strokes in beige.
- **Instructor Profiles:** Circular or soft-square imagery paired with an elegant H3 for the name and "label-caps" for the specialty.
- **Mood Indicators:** Small, tinted circles (using the palette) to categorize classes by energy level (e.g., Terracotta for Power, Beige for Restorative).