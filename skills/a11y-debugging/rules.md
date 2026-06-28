# Accessibility Debugging Rules

## 1. Keyboard Nav & Focus
- Ensure all interactive elements have visible focus states.
- Do not override default focus outlines unless presenting a custom keyboard-friendly focus style.
- Banish `tabindex > 0`. Keep DOM order natural.

## 2. ARIA & Screen Readers
- Prioritize semantic HTML5 tags over custom ARIA components.
- If using custom ARIA, require correct roles (`button`, `dialog`, `tablist`) and focus management.

## 3. Color Contrast
- Enforce a minimum contrast ratio of 4.5:1 for normal text and 3:1 for large text.
