
This function will perform demon registration which is an type of fast non-rigid fluid like registration between two 2D or 3D images. Registration between different (MRI) modalities is also supported, through a function which transform one image modality so it looks likes the modality of the second image.

The demon registration is described by the paper of Thirion 1998 and extended by Cachier 1999 and He Wang 2005.

Basic algorithm: On each pixel a velocity (movement) is defined with use of the intensity differences and gradient information. This velocity field is smoothed by an Gaussian, and iteratively used to transform the moving image, and register on to the static image. (Easy to understand code example in file basic_demon_example.m)

Instead of using the basic equations for the "demonregistration" function, we have rewritten it to be used by an limit memory BFGS optimizer in an iterative and multi-resolution way, with also support of diffusion regularization. (see also Tom Vercauteren et al. "Non-parametric Diffeomorphic Image..." )

Transforming one modality into the fake modality of the other image is done with use of 2D mutual histograms between regions of both images, and choosing the grey values which have the highest correlation. D. Kroon et al. "MRI Modality Transformation in Demon Registration" (MutualTransform.m)

See the screenshot for an example result.

Usage:
The functions register_images.m and register_volumes.m are easy to use, and will fit most applications.
First compile the c-code : compile_c_files.m.

Notes:
- All the mex-code is multi-threaded and is tested on both Windows and Linux.
- Please leave comments and report bugs

Cite As
Dirk-Jan Kroon (2022). multimodality non-rigid demon algorithm image registration (https://www.mathworks.com/matlabcentral/fileexchange/21451-multimodality-non-rigid-demon-algorithm-image-registration), MATLAB Central File Exchange. Retrieved July 25, 2022.





