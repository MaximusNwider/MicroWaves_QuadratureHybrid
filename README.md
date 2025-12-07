# Quadrature Hybrid Design Summary

<p align="justify">
This repository contains MATLAB tooling for comparing measured and simulated S-parameters of a quadrature hybrid. The pipeline ingests VNA Touchstone files alongside simulator exports, aligns the data to global S-parameter labels, and produces side-by-side comparison plots suitable for documentation and verification.
</p>

| Layout                                                   | Schematic                                                      |
| -------------------------------------------------------- | -------------------------------------------------------------- |
| ![Quadrature Hybrid Layout](QuadratureHybrid_Layout.png) | ![Quadrature Hybrid Schematic](QuadratureHybrid_Schematic.png) |

| ADS Simulation                                                     |
| ------------------------------------------------------------------ |
| ![Quadrature Hybrid Simulation Overview](QuadratureHybrid_Sim.png) |

---

## Design Criteria

- **Center frequency:** 2.45 GHz
- **Return loss at all ports:** S11, S22, S33, S44 < -25 dB at 2.45 GHz
- **Power division:** S21 and S31 > -3.5 dB at 2.45 GHz
- **Isolation:** S41 < -30 dB at 2.45 GHz
- **Phase balance:** ∠S21 – ∠S31 = 90° at 2.45 GHz

---

## Substrate Properties

- **Substrate thickness (h):** 62 mil
- **Relative permittivity (εᵣ):** 4.4
- **Relative permeability (μᵣ):** 1
- **Conductor conductivity (σ):** 5.85 × 10⁷ S/m
- **Clearance to upper reference (hᵤ):** 3.93701 × 10³⁴ mil (effectively open)
- **Copper thickness (t):** 1.5 mil
- **Dielectric loss tangent (tan δ):** 0.02
- **Surface roughness:** 0 mil

---

## Repository Layout

- `main.m` — entry point that sets up paths, loads configuration, and launches the pipeline.
- `run_sparam_project.m` — orchestrates file discovery, measurement/simulation alignment, and plotting.
- `+config/` — default configuration values (paths, plotting options, axis limits).
- `+io/` — parsers for measurement (`*.s2p`) and simulation (`*.txt` / `*.tab` / `*.dat`) data.
- `+plotting/` — routines that generate comparison figures and save them to `output/`.
- `+util/` — helpers for path management and filename parsing.
- `+data/` — sample measurement and simulation files for local runs.
- `output/` — generated figures (`Sij.png`) for each available S-parameter.
- `QuadratureHybrid_*.png` — reference layout, schematic, and simulation overview images.
- `gerber/` — layout description, fabrication-ready.

---

## Running the Code

1. Open MATLAB and change into the repository folder.
2. Run the project entry point:

   ```matlab
   >> main
   ```

<p align="justify">
The script will read measurement and simulation files from the configured directories, map the local two-port VNA data to the appropriate global S-parameter labels, and write comparison plots into the <code>output/</code> directory for inspection and documentation.
</p>

---

## Measurement vs. Simulation

| S11                                                     | S12                                                     |
| ------------------------------------------------------- | ------------------------------------------------------- |
| <figure><img src="output/S11.png" alt="S11" /></figure> | <figure><img src="output/S12.png" alt="S12" /></figure> |

| S13                                                     | S14                                                     |
| ------------------------------------------------------- | ------------------------------------------------------- |
| <figure><img src="output/S13.png" alt="S13" /></figure> | <figure><img src="output/S14.png" alt="S14" /></figure> |

| S21                                                     | S22                                                     |
| ------------------------------------------------------- | ------------------------------------------------------- |
| <figure><img src="output/S21.png" alt="S21" /></figure> | <figure><img src="output/S22.png" alt="S22" /></figure> |

| S23                                                     | S31                                                     |
| ------------------------------------------------------- | ------------------------------------------------------- |
| <figure><img src="output/S23.png" alt="S23" /></figure> | <figure><img src="output/S31.png" alt="S31" /></figure> |

| S32                                                     | S33                                                     |
| ------------------------------------------------------- | ------------------------------------------------------- |
| <figure><img src="output/S32.png" alt="S32" /></figure> | <figure><img src="output/S33.png" alt="S33" /></figure> |

| S41                                                     | S44                                                     |
| ------------------------------------------------------- | ------------------------------------------------------- |
| <figure><img src="output/S41.png" alt="S41" /></figure> | <figure><img src="output/S44.png" alt="S44" /></figure> |
