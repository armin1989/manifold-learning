# manifold-learning
This repo contains the demo files for the paper "Manifold Learning via the Principle Bundle Approach".

This paper was published in journal of Frontiers in Applied Mathematics and Statistics

Abstract: In this paper, we propose a novel principal bundle model and apply it to the image denoising problem. This model is based on the fact that the patch manifold admits canonical groups actions such as rotation. We introduce an image denoising algorithm, called the diffusive vector non-local Euclidean median (dvNLEM), by combining the traditional nonlocal Euclidean median (NLEM), the rotational structure in the patch space, and the diffusion distance. A theoretical analysis of dvNLEM, as well as the traditional nonlocal Euclidean median (NLEM), is provided to explain why these algorithms work. In particular, we show how accurate we could obtain the true neighbors associated with the rotationally invariant distance (RID) and Euclidean distance in the patch space when noise exists, and how we could apply the diffusion geometry to stabilize the selected metric. The dvNLEM is applied to an image database of 1,361 images and a comparison with the NLEM is provided. Different image quality assessments based on the error-sensitivity or the human visual system are applied to evaluate the performance.

Link to our paper: https://www.frontiersin.org/articles/10.3389/fams.2018.00021/full

Start the demo from main.m file, the mex files do most of the heavy liftin in C and may need to be re-compiled.
