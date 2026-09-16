# Vastu Plot Analyzer – Flexible VPM Prototype

A Flutter Android prototype for overlaying a Vastu Purusha Mandala on a plot photograph.

## Core workflow
1. Select a plot photo.
2. Add **any number of boundary points** (not limited to 4).
3. Drag points to match every corner/bend of an irregular plot; delete or reset points when needed.
4. Enter plot width/length and a North/reference rotation degree.
5. The app draws a clipped 9×9 construction over the polygon, highlights the central 3×3 Brahmasthan and labels cells with VPM reference numbers/deity names.
6. Tap a cell to see its deity reference.
7. Export a basic PDF report.

## Reference-driven design
The project is intended to evolve toward the supplied GeoGebra/RealVaastu-style construction: 45 Devata, 32 outer door padas, 16 zones, marma points, affected/cut-area analysis, and a professional PDF report.

The current implementation is a prototype and **does not claim to reproduce any third-party site's proprietary implementation or to establish a universally accepted Vastu prescription**. Devata spelling, numbering and placement can differ between Vastu traditions; keep the reference table/configuration editable and validate the chosen tradition before using the app for professional advice.

## GitHub APK build
Push the repository to GitHub, then use **Actions → Build Android APK**. The workflow creates the Android platform files, installs packages, builds a release APK and uploads it as an artifact.

## Next engineering modules
- Perspective/plan calibration using selected boundary points.
- True polygon clipping/intersection percentages for every pada/deity.
- Independent layer switches: VPM / 16 zones / 32 door padas / marma points / dimensions.
- Deity detail database with configurable traditional remedies.
- Crystal and colour suggestions as clearly labelled traditional/faith-based guidance, not medical treatment.
- Professional multi-page PDF with plot image, overlay, deity table and affected-area summary.


## GitHub Actions fix

The workflow explicitly uses `--project-name vastu_plot_analyzer` so the build also works when the GitHub repository/folder has a name containing hyphens or other characters that are invalid for a Dart package name.
