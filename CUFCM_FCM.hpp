#pragma once
#include "config.hpp"

///////////////////////////////////////////////////////////////////////////////
// Fast FCM
///////////////////////////////////////////////////////////////////////////////
__global__
void cufcm_precompute_gauss(int N, int ngd, Real* Y,
                    Real* gaussx_, Real* gaussy, Real* gaussz,
                    Real* grad_gaussx_dip, Real* grad_gaussy_dip, Real* grad_gaussz_dip,
                    Real* gaussgrid,
                    Real* xdis, Real* ydis, Real* zdis,
                    int* indx, int* indy, int* indz,
                    Real sigmadipsq, Real anorm, Real anorm2, Real dx);

__global__
void cufcm_mono_dipole_distribution_tpp_register(myCufftReal *fx, myCufftReal *fy, myCufftReal *fz, int N,
              Real *T, Real *F, Real pdmag, Real sigmasq, 
              Real *gaussx, Real *gaussy, Real *gaussz,
              Real *grad_gaussx_dip, Real *grad_gaussy_dip, Real *grad_gaussz_dip,
              Real *xdis, Real *ydis, Real *zdis,
              int *indx, int *indy, int *indz,
              int ngd);

__global__
void cufcm_mono_dipole_distribution_tpp_recompute(myCufftReal *fx, myCufftReal *fy, myCufftReal *fz,
              Real *Y, Real *T, Real *F,
              int N, int ngd, 
              Real pdmag, Real sigmasq, Real sigmadipsq,
              Real anorm, Real anorm2,
              Real dx);

__global__
void cufcm_mono_dipole_distribution_bpp_shared(myCufftReal *fx, myCufftReal *fy, myCufftReal *fz, Real *Y,
              Real *T, Real *F, int N, int ngd, 
              Real pdmag, Real sigmasq, Real sigmadipsq,
              Real anorm, Real anorm2,
              Real dx);

__global__
void cufcm_mono_dipole_distribution_bpp_recompute(myCufftReal *fx, myCufftReal *fy, myCufftReal *fz, Real *Y,
              Real *T, Real *F, int N, int ngd, 
              Real pdmag, Real sigmasq, Real sigmadipsq,
              Real anorm, Real anorm2,
              Real dx);

__global__
void cufcm_flow_solve(myCufftComplex* fk_x, myCufftComplex* fk_y, myCufftComplex* fk_z,
                      myCufftComplex* uk_x, myCufftComplex* uk_y, myCufftComplex* uk_z,
                      Real* q, Real* qpad, Real* qsq, Real* qpadsq);

__global__
void cufcm_particle_velocities_tpp_register(myCufftReal *ux, myCufftReal *uy, myCufftReal *uz, int N,
                               Real *VTEMP, Real *WTEMP,
                               Real pdmag, Real sigmasq, 
                               Real *gaussx, Real *gaussy, Real *gaussz,
                               Real *grad_gaussx_dip, Real *grad_gaussy_dip, Real *grad_gaussz_dip,
                               Real *xdis, Real *ydis, Real *zdis,
                               int *indx, int *indy, int *indz,
                               int ngd, Real dx);

__global__
void cufcm_particle_velocities_tpp_recompute(myCufftReal *ux, myCufftReal *uy, myCufftReal *uz,
                                Real *Y,
                                Real *VTEMP, Real *WTEMP,
                                int N, int ngd, 
                                Real pdmag, Real sigmasq, Real sigmadipsq,
                                Real anorm, Real anorm2,
                                Real dx);

__global__
void cufcm_particle_velocities_bpp_shared(myCufftReal *ux, myCufftReal *uy, myCufftReal *uz,
                                Real *Y,
                                Real *VTEMP, Real *WTEMP,
                                int N, int ngd, 
                                Real pdmag, Real sigmasq, Real sigmadipsq,
                                Real anorm, Real anorm2,
                                Real dx);

__global__
void cufcm_particle_velocities_bpp_recompute(myCufftReal *ux, myCufftReal *uy, myCufftReal *uz,
                                Real *Y,
                                Real *VTEMP, Real *WTEMP,
                                int N, int ngd, 
                                Real pdmag, Real sigmasq, Real sigmadipsq,
                                Real anorm, Real anorm2,
                                Real dx);

///////////////////////////////////////////////////////////////////////////////
// Regular FCM
///////////////////////////////////////////////////////////////////////////////
__global__
void cufcm_mono_dipole_distribution_regular_fcm(myCufftReal *fx, myCufftReal *fy, myCufftReal *fz, Real *Y,
              Real *T, Real *F, int N, int ngd, 
              Real pdmag, Real sigmasq, Real sigmadipsq,
              Real anorm, Real anorm2,
              Real dx);

__global__
void cufcm_particle_velocities_regular_fcm(myCufftReal *ux, myCufftReal *uy, myCufftReal *uz,
                                Real *Y,
                                Real *VTEMP, Real *WTEMP,
                                int N, int ngd, 
                                Real pdmag, Real sigmasq, Real sigmadipsq,
                                Real anorm, Real anorm2,
                                Real dx);

///////////////////////////////////////////////////////////////////////////////
// CPU code
///////////////////////////////////////////////////////////////////////////////
void cufcm_precompute_gauss_loop(int N, int ngd, Real* Y,
                    Real* gaussx_, Real* gaussy, Real* gaussz,
                    Real* grad_gaussx_dip, Real* grad_gaussy_dip, Real* grad_gaussz_dip,
                    Real* gaussgrid,
                    Real* xdis, Real* ydis, Real* zdis,
                    int* indx, int* indy, int* indz,
                    Real sigmadipsq, Real anorm, Real anorm2, Real dx);

void cufcm_mono_dipole_distribution_tpp_loop(myCufftReal *fx, myCufftReal *fy, myCufftReal *fz, int N,
              Real *T, Real *F, Real pdmag, Real sigmasq, 
              Real *gaussx, Real *gaussy, Real *gaussz,
              Real *grad_gaussx_dip, Real *grad_gaussy_dip, Real *grad_gaussz_dip,
              Real *xdis, Real *ydis, Real *zdis,
              int *indx, int *indy, int *indz,
              int ngd);

void cufcm_particle_velocities_loop(myCufftReal *ux, myCufftReal *uy, myCufftReal *uz, int N,
                               Real *VTEMP, Real *WTEMP,
                               Real pdmag, Real sigmasq, 
                               Real *gaussx, Real *gaussy, Real *gaussz,
                               Real *grad_gaussx_dip, Real *grad_gaussy_dip, Real *grad_gaussz_dip,
                               Real *xdis, Real *ydis, Real *zdis,
                               int *indx, int *indy, int *indz,
                               int ngd, Real dx);

__device__ __host__
Real int_pow(Real base, int power);

///////////////////////////////////////////////////////////////////////////////
// Test functions
///////////////////////////////////////////////////////////////////////////////
void cufcm_test_force_loop(myCufftReal* fx, myCufftReal* fy, myCufftReal* fz);

__global__
void cufcm_test_force(myCufftReal* fx, myCufftReal* fy, myCufftReal* fz);

__global__
void normalise_array(myCufftReal* ux, myCufftReal* uy, myCufftReal* uz);