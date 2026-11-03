# Optimized Averaged Kaczmarz Framework for Efficient Multi-Orientation Inversion in Quantitative Susceptibility Mapping

Sejal Maisheri, Ambedkar Dukkipati, and Phaneendra K. Yalavarthy, "Optimized Averaged Kaczmarz Framework for Efficient Multi-Orientation Inversion in Quantitative Susceptibility Mapping," IEEE Transactions on Biomedical Engineering (2026). (in press)

OMNIS (Optimized Multi-orientation Nonlinear Inversion of Susceptibility) is a multi-orientation QSM (Quantitative Susceptibility Mapping) reconstruction method that integrates averaged Kaczmarz-style iterative updates with a nonlinear data fidelity formulation. It achieves improved reconstruction quality while reducing both computational burden and acquisition requirements, providing a practical and clinically viable framework for Multi Orientation QSM reconstruction. It also showcases the potential to serve as a reliable in vivo reference standard for evaluating single-orientation QSM reconstruction methods.

This repository contains the official implementation of **OMNIS QSM** and a detailed description for generating the multi-orientation simulated dataset used in this study. 

## Dataset

Original RC2 single orientation simulated framework data and code:
https://doi.org/10.34973/m20r-jt17

Details of extending to multiorientation settings are given in: 
`Data_generation.m` 

Sample multi orientation simulated dataset generated for this study can be downloaded from: 
( will be updated later)

In vivo 2016 QSM Challenge Dataset used in this study:
http://qsm.neuroimaging.at


## OMNIS Framework Code

The `main.m` script contains the implementation of OMNIS, compares it with existing multi-orientation QSM reconstruction methods (COSMOS and NDI), and evaluates reconstruction quality using ROI error, NRMSE, PSNR, SSIM, and HFEN.

```
 main.m
```

## Implementation Details

- **OMNIS Validation Experiments:** MATLAB R2026a
- **Simulation Dataset Generation:** MATLAB R2025b
- **Simulated Data Preprocessing:** SEPIA Toolbox v1.2.2.6

SEPIA Documentation: https://sepia-documentation.readthedocs.io/en/latest/index.html


## Citation

If you use OMNIS, multi-orientation simulation dataset, or any part of this study in your research, please cite the following:

```bibtex
@article{maisheri2026_OMNIS_QSM,
  title   = {Optimized Averaged Kaczmarz Framework for Efficient Multi-Orientation Inversion in Quantitative Susceptibility Mapping},
  author  = {Maisheri, Sejal and Dukkipati, Ambedkar and Yalavarthy, Phaneendra K.},
  journal = {IEEE Transactions on Biomedical Engineering},
  note    = {in press},
  year    = {2026}
}
```

## Contact

For any questions or to request the complete multi-orientation simulated dataset, please feel free to reach out:

*Sejal Maisheri*

PhD Scholar, IMI, IISc Bangalore, Email: sejalm@iisc.ac.in 


*Prof. Phaneendra K. Yalavarthy*

Professor, CDS, IISC Bangalore, Email: yalavarthy@iisc.ac.in
