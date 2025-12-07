# Quadrature Hybrid Design Summary

This repository contains MATLAB tooling for comparing measured and simulated S-parameters of a quadrature hybrid. The pipeline ingests VNA touchstone files alongside simulator exports, aligns the data to global S-parameter labels, and produces side-by-side comparison plots.

## Design Criteria

- **Center frequency:** 2.45 GHz.
- **Return loss at all ports:** S11, S22, S33, S44 < -25 dB at 2.45 GHz.
- **Power division:** S21 and S31 > -3.5 dB at 2.45 GHz.
- **Isolation:** S41 < -30 dB at 2.45 GHz.
- **Phase balance:** Angle(S21) – Angle(S31) = 90° at 2.45 GHz.

| Layout                                                   | Schematic                                                      | Simulation Overview                                                |
| -------------------------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------ |
| ![Quadrature Hybrid Layout](QuadratureHybrid_Layout.png) | ![Quadrature Hybrid Schematic](QuadratureHybrid_Schematic.png) | ![Quadrature Hybrid Simulation Overview](QuadratureHybrid_Sim.png) |

## Repository layout

- `main.m` — entry point that sets up paths, loads configuration, and launches the pipeline.
- `run_sparam_project.m` — orchestrates file discovery, measurement/simulation alignment, and plotting.
- `+config/` — default configuration values (paths, plotting options, axis limits).
- `+io/` — parsers for measurement (`*.s2p`) and simulation (`*.txt`/`*.tab`/`*.dat`) data.
- `+plotting/` — routines that generate comparison figures and save them to `output/`.
- `+util/` — helpers for path management and filename parsing.
- `+data/` — sample measurement and simulation files for local runs.
- `output/` — generated figures (`Sij.png`) for each available S-parameter.
- `QuadratureHybrid_*.png` — reference layout, schematic, and simulation overview images.

## Design Criteria

## Running the code

1. Open MATLAB and change into the repository folder.
2. Run the project entry point:
   ```matlab
   >> main
   ```
   The script will read measurement and simulation files from the configured directories, then write comparison plots to `output/`.

## Measurement vs. Simulation

| S11                                                                                 | S12                                                                                 |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| <figure><img src="output/S11.png" alt="S11" /><figcaption>S11</figcaption></figure> | <figure><img src="output/S12.png" alt="S12" /><figcaption>S12</figcaption></figure> |

| S13                                                                                 | S14                                                                                 |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| <figure><img src="output/S13.png" alt="S13" /><figcaption>S13</figcaption></figure> | <figure><img src="output/S14.png" alt="S14" /><figcaption>S14</figcaption></figure> |

| S21                                                                                 | S22                                                                                 |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| <figure><img src="output/S21.png" alt="S21" /><figcaption>S21</figcaption></figure> | <figure><img src="output/S22.png" alt="S22" /><figcaption>S22</figcaption></figure> |

| S23                                                                                 | S31                                                                                 |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| <figure><img src="output/S23.png" alt="S23" /><figcaption>S23</figcaption></figure> | <figure><img src="output/S31.png" alt="S31" /><figcaption>S31</figcaption></figure> |

| S32                                                                                 | S33                                                                                 |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| <figure><img src="output/S32.png" alt="S32" /><figcaption>S32</figcaption></figure> | <figure><img src="output/S33.png" alt="S33" /><figcaption>S33</figcaption></figure> |

| S41                                                                                 | S44                                                                                 |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| <figure><img src="output/S41.png" alt="S41" /><figcaption>S41</figcaption></figure> | <figure><img src="output/S44.png" alt="S44" /><figcaption>S44</figcaption></figure> |
