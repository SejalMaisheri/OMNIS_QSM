# OMNIS_QSM
# OMNIS: Optimization Framework for Multi-Orientation Quantitative Susceptibility Mapping

Official implementation of:

**"OMNIS: Optimization Multi-Orientation Non-linear Inversion of Susceptibility for Quantitative Susceptibility Mapping"**

> [Author List]
> [Conference/Journal Name, Year]

---

## Overview


## Repository Structure

```text
.
├── main_omnis.m                    # Main reconstruction script
├── config/
│   └── reconstruction_params.m     # Reconstruction parameters
├── functions/                      # Core reconstruction functions
├── simulation/
│   ├── generate_multiori_data.m    # Multi-orientation data generation
│   └── README_multiori.txt         # Details for generating new datasets
├── data/
│   └── sample_data/
├── results/
├── figures/
└── README.md
```

---

## Sample Dataset

A small sample dataset is provided for testing and reproducing the example reconstruction.

### Download Sample Dataset

Download from:

**[INSERT SAMPLE DATASET LINK]**

After downloading, place the extracted folder inside:

```text
data/sample_data/
```

---

## Original Single-Orientation Simulation Dataset

The multi-orientation simulation framework used in this work is based on the realistic single-orientation simulation framework introduced in:

> [Reference to original simulation work]

The original dataset and generation framework can be downloaded from:

**[INSERT ORIGINAL DATASET LINK]**

Please download the original dataset before generating additional multi-orientation datasets.

---

## Generating Multi-Orientation Simulation Data

The script

```text
simulation/generate_multiori_data.m
```

creates realistic multi-orientation QSM datasets from the original simulation framework.

Detailed instructions regarding:

* orientation specification
* rotation matrices
* dipole kernel generation
* forward simulation
* output file organization

are provided in:

```text
simulation/README_multiori.txt
```

Users wishing to create custom multi-orientation datasets should consult this file before running the generation script.

---

## Installation

### Requirements

MATLAB R2022a or later is recommended.



## Running OMNIS

### Example Reconstruction

Run:

```matlab
main_omnis
```

or

```matlab
main_omnis('data/sample_data')
```

depending on your setup.

### Input Data

The reconstruction requires:

```text
Local field maps
Brain mask
Orientation information
Voxel size
B0 direction
```

### Configuration

Reconstruction parameters can be modified in:

```text
config/reconstruction_params.m
```

Key parameters include:

```text
Number of iterations
Regularization parameters
Step size
Orientation weights
Stopping tolerance
```

---

## Output

The reconstruction outputs:

```text
Susceptibility map (.mat)
Intermediate reconstructions (optional)
Quantitative metrics
Reconstruction logs
```

Results are saved to:

```text
results/
```

---



## Citation

If you use this code in your research, please cite:

```bibtex
@article{OMNIS2026,
  title={OMNIS: An Optimization Framework for Multi-Orientation Quantitative Susceptibility Mapping},
  author={[Authors]},
  journal={[Journal/Conference]},
  year={2026}
}
```

---


## Contact

For questions, bug reports, or collaboration inquiries:

**Sejal Maisheri**
Email: [your_email@domain.com](mailto:your_email@domain.com)

or open an issue on this repository.

---

## Acknowledgements

The multi-orientation simulation framework builds upon the publicly available realistic QSM simulation framework developed by the original authors. We gratefully acknowledge their contribution to the QSM research community.
