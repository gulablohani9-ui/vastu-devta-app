# Vastu Plot Analyzer V2.1

GitHub-ready Flutter prototype for flexible polygon plot analysis.

## Important rotation behavior
- Enter the North / rotation degree for the plot.
- The **Vastu geometry/grid rotates with the degree** relative to the uploaded plot image.
- **Pada numbers, Devata names, N/S/E/W labels, and other text remain upright and readable**; they are counter-rotated against the geometry.
- Boundary points remain editable and can be added, moved, or deleted.

## Build
Use GitHub Actions workflow in `.github/workflows/build-apk.yml`.
