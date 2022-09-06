#include <cufft.h>

#ifndef CONFIG_H
#define CONFIG_H

#define PI 3.14159265358979
#define PI2 6.28318530717959
#define PI2sqrt 2.5066282746310002
#define TWOoverPIsqrt 0.7978845608028654
#define PI2sqrt_inv 0.3989422804014327

#define NX 256.0
#define NY 256.0
#define NZ 256.0
#define NPTS 256.0
#define NGD 9

#define GRID_SIZE (NX*NY*NZ)
#define FFT_GRID_SIZE ((NX/2+1)*NY*NZ)

#define THREADS_PER_BLOCK 32

#define BATCH 10

#define RANK 1

#define HASH_ENCODE_FUNC linear_encode

#define PARALLELISATION_TYPE 2
// 0 = Thread per particle (TPP) register
// 1 = Thread per particle (TPP) recompute
// 2 = Block per particle (BPP) shared
// 3 = Block per particle (BPP) recompute

#define SPATIAL_HASHING 0
// 0 = Spatial hashing for correction, but without sorting
// 1 = Spatial hashing and sorting

#define CORRECTION_TYPE 1
// 0 = linklist
// 1 = spatial hashing

#define USE_DOUBLE_PRECISION true

#if USE_DOUBLE_PRECISION
    typedef double Real;
    typedef cufftDoubleReal myCufftReal;
    typedef cufftDoubleComplex myCufftComplex;
    #define cufftComplex2Real CUFFT_Z2D
    #define cufftReal2Complex CUFFT_D2Z
    #define cufftExecReal2Complex cufftExecD2Z
    #define cufftExecComplex2Real cufftExecZ2D
#else
    typedef float Real;
    typedef cufftReal myCufftReal;
    typedef cufftComplex myCufftComplex;
    #define cufftComplex2Real CUFFT_C2R
    #define cufftReal2Complex CUFFT_R2C
    #define cufftExecReal2Complex cufftExecR2C
    #define cufftExecComplex2Real cufftExecC2R
#endif

#endif