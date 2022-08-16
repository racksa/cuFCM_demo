#include <iostream>
#include <cmath>
// Include CUDA runtime and CUFFT
#include <cuda_runtime.h>
#include <cufft.h>


#include "cuda_util.hpp"
#include "config.hpp"
#include "CUFCM_FCM.hpp"
#include "CUFCM_util.hpp"
#include "CUFCM_data.hpp"

#define PI 3.14159265358979
#define PI2 6.28318530717959
#define PI2sqrt 2.5066282746310002
#define TWOoverPIsqrt 0.7978845608028654
#define PI2sqrt_inv 0.3989422804014327

int main(int argc, char** argv) {

	///////////////////////////////////////////////////////////////////////////////
	// Initialise parameters
	///////////////////////////////////////////////////////////////////////////////

	int N = 1000;

	int ngd = 11;

	double sigma_fac = 1.0;

	double dx = (PI2)/(NX);

	/* Monopole */
	const double rh = 0.02609300415934458;
	const double sigmaFCM = rh/sqrt(PI); // Real particle size sigmaFCM
	const double sigmaFCMsq = sigmaFCM*sigmaFCM;
	const double anormFCM = 1.0/sqrt(2.0*PI*sigmaFCMsq);
	const double anormFCM2 = 2.0*sigmaFCMsq;

	const double sigmaGRID = sigmaFCM * sigma_fac;
	const double sigmaGRIDsq = sigmaGRID * sigmaGRID;
	const double anormGRID = 1.0/sqrt(2.0*PI*sigmaGRIDsq);
	const double anormGRID2 = 2.0*sigmaGRIDsq;

	const double gammaGRID = sqrt(2.0)*sigmaGRID;
	const double pdmag = sigmaFCMsq - sigmaGRIDsq;

	/* Dipole */
	const double sigmaFCMdip = rh/pow(6.0*sqrt(PI), 1.0/3.0);
	const double sigmaFCMdipsq = sigmaFCMdip*sigmaFCMdip;
	const double anormFCMdip = 1.0/sqrt(2.0*PI*sigmaFCMdipsq);
	const double anormFCMdip2 = 2.0*sigmaFCMdipsq;

	const double sigma_dip_fac = sigmaGRID/sigmaFCMdip;
	// sigma_dip_fac = 1;

	const double sigmaGRIDdip = sigmaFCMdip * sigma_dip_fac;
	const double sigmaGRIDdipsq = sigmaGRIDdip * sigmaGRIDdip;
	const double anormGRIDdip = 1.0/sqrt(2.0*PI*sigmaGRIDdipsq);
	const double anormGRIDdip2 = 2.0*sigmaGRIDdipsq;

	/* Self corrections */
	const double StokesMob = 1.0/(6.0*PI*rh);
	const double ModStokesMob = 1.0/(6.0*PI*sigmaGRID*sqrt(PI));

	double PDStokesMob = 2.0/pow(2.0*PI, 1.5);
	PDStokesMob = PDStokesMob/pow(gammaGRID, 3.0);
	PDStokesMob = PDStokesMob*pdmag/3.0;

	double BiLapMob = 1.0/pow(4.0*PI*sigmaGRIDsq, 1.5);
	BiLapMob = BiLapMob/(4.0*sigmaGRIDsq)*pdmag*pdmag;

	const double WT1Mob = 1.0/(8.0*PI)/pow(rh, 3) ;
	const double WT2Mob = 1.0/(8.0*PI)/pow(sigmaGRIDdip*pow(6.0*sqrt(PI), 1.0/3.0), 3) ;


	///////////////////////////////////////////////////////////////////////////////
	// CUDA initialisation
	///////////////////////////////////////////////////////////////////////////////
    cufftHandle plan, iplan;

	cufftReal* fx_host = malloc_host<cufftReal>(GRID_SIZE);					cufftReal* fx_device = malloc_device<cufftReal>(GRID_SIZE);
	cufftReal* fy_host = malloc_host<cufftReal>(GRID_SIZE);					cufftReal* fy_device = malloc_device<cufftReal>(GRID_SIZE);
	cufftReal* fz_host = malloc_host<cufftReal>(GRID_SIZE);					cufftReal* fz_device = malloc_device<cufftReal>(GRID_SIZE);
    cufftComplex* fk_x_host = malloc_host<cufftComplex>(FFT_GRID_SIZE);		cufftComplex* fk_x_device = malloc_device<cufftComplex>(FFT_GRID_SIZE);
    cufftComplex* fk_y_host = malloc_host<cufftComplex>(FFT_GRID_SIZE);		cufftComplex* fk_y_device = malloc_device<cufftComplex>(FFT_GRID_SIZE);
    cufftComplex* fk_z_host = malloc_host<cufftComplex>(FFT_GRID_SIZE);		cufftComplex* fk_z_device = malloc_device<cufftComplex>(FFT_GRID_SIZE);

	cufftReal* ux_host = malloc_host<cufftReal>(GRID_SIZE);					cufftReal* ux_device = malloc_device<cufftReal>(GRID_SIZE);
	cufftReal* uy_host = malloc_host<cufftReal>(GRID_SIZE);					cufftReal* uy_device = malloc_device<cufftReal>(GRID_SIZE);
	cufftReal* uz_host = malloc_host<cufftReal>(GRID_SIZE);					cufftReal* uz_device = malloc_device<cufftReal>(GRID_SIZE);
    cufftComplex* uk_x_host = malloc_host<cufftComplex>(FFT_GRID_SIZE);		cufftComplex* uk_x_device = malloc_device<cufftComplex>(FFT_GRID_SIZE);
    cufftComplex* uk_y_host = malloc_host<cufftComplex>(FFT_GRID_SIZE);		cufftComplex* uk_y_device = malloc_device<cufftComplex>(FFT_GRID_SIZE);
    cufftComplex* uk_z_host = malloc_host<cufftComplex>(FFT_GRID_SIZE);		cufftComplex* uk_z_device = malloc_device<cufftComplex>(FFT_GRID_SIZE);

	double* Y_host = malloc_host<double>(3*N);					double* Y_device = malloc_device<double>(3*N);
	double* F_host = malloc_host<double>(3*N);					double* F_device = malloc_device<double>(3*N);
	double* T_host = malloc_host<double>(3*N);					double* T_device = malloc_device<double>(3*N);
	double* V_host = malloc_host<double>(3*N);					double* V_device = malloc_device<double>(3*N);
	double* W_host = malloc_host<double>(3*N);					double* W_device = malloc_device<double>(3*N);
	double* GA_host = malloc_host<double>(6*N);					double* GA_device = malloc_device<double>(6*N);

	double* gaussx_host = malloc_host<double>(ngd*N);			double* gaussx_device = malloc_device<double>(ngd*N);
	double* gaussy_host = malloc_host<double>(ngd*N);			double* gaussy_device = malloc_device<double>(ngd*N);
	double* gaussz_host = malloc_host<double>(ngd*N);			double* gaussz_device = malloc_device<double>(ngd*N);
	double* grad_gaussx_dip_host = malloc_host<double>(ngd*N);	double* grad_gaussx_dip_device = malloc_device<double>(ngd*N);
	double* grad_gaussy_dip_host = malloc_host<double>(ngd*N);	double* grad_gaussy_dip_device = malloc_device<double>(ngd*N);
	double* grad_gaussz_dip_host = malloc_host<double>(ngd*N);	double* grad_gaussz_dip_device = malloc_device<double>(ngd*N);
	double* gaussgrid_host = malloc_host<double>(ngd);			double* gaussgrid_device = malloc_device<double>(ngd);
	double* xdis_host = malloc_host<double>(ngd*N);				double* xdis_device = malloc_device<double>(ngd*N);
	double* ydis_host = malloc_host<double>(ngd*N);				double* ydis_device = malloc_device<double>(ngd*N);
	double* zdis_host = malloc_host<double>(ngd*N);				double* zdis_device = malloc_device<double>(ngd*N);
	int* indx_host = malloc_host<int>(ngd*N);					int* indx_device = malloc_device<int>(ngd*N);
	int* indy_host = malloc_host<int>(ngd*N);					int* indy_device = malloc_device<int>(ngd*N);
	int* indz_host = malloc_host<int>(ngd*N);					int* indz_device = malloc_device<int>(ngd*N);

	/* Create 3D FFT plans */
	cufftPlan3d(&plan, NX, NY, NZ, CUFFT_R2C);
	cufftPlan3d(&iplan, NX, NY, NZ, CUFFT_C2R);

	const int num_thread_blocks = (GRID_SIZE + THREADS_PER_BLOCK - 1)/THREADS_PER_BLOCK;

	///////////////////////////////////////////////////////////////////////////////
	// Wave vector initialisation
	///////////////////////////////////////////////////////////////////////////////

	int pad = (NX/2 + 1);
	int nptsh = (NX/2);
	double* q_host = malloc_host<double>(NX);			double* q_device = malloc_device<double>(NX);
	double* qpad_host = malloc_host<double>(pad);		double* qpad_device = malloc_device<double>(pad);
	double* qsq_host = malloc_host<double>(NX);			double* qsq_device = malloc_device<double>(NX);
	double* qpadsq_host = malloc_host<double>(pad);		double* qpadsq_device = malloc_device<double>(pad);

	for(int i=0; i<NX; i++){
		if(i < nptsh || i == nptsh){
			q_host[i] = (double) i;
		}
		if(i > nptsh){
			q_host[i] = (double) (i - NX);
		}
		qsq_host[i] = q_host[i]*q_host[i];
	}
	
	for(int i=0; i<pad; i++){
		qpad_host[i] = (double) i;
		qpadsq_host[i] = qpad_host[i]*qpad_host[i];
	}
	copy_to_device<double>(q_host, q_device, NX);
	copy_to_device<double>(qpad_host, qpad_device, pad);
	copy_to_device<double>(qsq_host, qsq_device, NX);
	copy_to_device<double>(qpadsq_host, qpadsq_device, pad);

	///////////////////////////////////////////////////////////////////////////////
	// Physical system initialisation
	///////////////////////////////////////////////////////////////////////////////
	read_init_data(Y_host, N, "./init_data/pos-N500000-rh02609300.dat");
	read_init_data(F_host, N, "./init_data/force-N500000-rh02609300.dat");
	read_init_data(T_host, N, "./init_data/force-N500000-rh02609300-2.dat");

	///////////////////////////////////////////////////////////////////////////////
	// Gaussian initialisation
	///////////////////////////////////////////////////////////////////////////////
	cufcm_gaussian_setup(N, ngd, Y_host,
				   gaussx_host, gaussy_host, gaussz_host,
				   grad_gaussx_dip_host, grad_gaussy_dip_host, grad_gaussz_dip_host,
				   gaussgrid_host,
				   xdis_host, ydis_host, zdis_host,
				   indx_host, indy_host, indz_host,
				   sigmaGRIDdipsq, anormGRID, anormGRID2, dx);

	GA_setup(GA_host, T_host, N);

	// print_host_data_real_3D_flat<double>(Y_host, N, 3);
	// print_host_data_real_3D_flat<double>(xdis_host, N, ngd);
	// print_host_data_real_3D_flat<double>(gaussgrid_host, 1, ngd);

	///////////////////////////////////////////////////////////////////////////////
	// Spreading
	///////////////////////////////////////////////////////////////////////////////
	// cufcm_force_distribution<<<num_thread_blocks, THREADS_PER_BLOCK>>>(fx_host, fy_host, fz_host);
	// print_host_data_real_3D_indexstyle<cufftReal>(fx_host, fy_host, fz_host);
	// /* Copy data to device */

	// cufcm_test_force<<<num_thread_blocks, THREADS_PER_BLOCK>>>(fx_device, fy_device, fz_device);
	cufcm_mono_dipole_distribution(fx_host, fy_host, fz_host, N,
								   GA_host, F_host, pdmag, sigmaGRIDsq,
								   gaussx_host, gaussy_host, gaussz_host,
								   grad_gaussx_dip_host, grad_gaussy_dip_host, grad_gaussz_dip_host,
								   xdis_host, ydis_host, zdis_host,
								   indx_host, indy_host, indz_host,
								   ngd);

	copy_to_device<cufftReal>(fx_host, fx_device, GRID_SIZE);
	copy_to_device<cufftReal>(fy_host, fy_device, GRID_SIZE);
	copy_to_device<cufftReal>(fz_host, fz_device, GRID_SIZE);
	
	// copy_to_host<cufftReal>(fx_device, fx_host, GRID_SIZE);
	// copy_to_host<cufftReal>(fy_device, fy_host, GRID_SIZE);
	// copy_to_host<cufftReal>(fz_device, fz_host, GRID_SIZE);
	// print_host_data_real_3D_indexstyle(fx_host, fy_host, fz_host);

	// print_host_data_real_3D_flat<cufftReal>(fx_host, NX, 1);

	///////////////////////////////////////////////////////////////////////////////
	// FFT
	///////////////////////////////////////////////////////////////////////////////
	if (cufftExecR2C(plan, fx_device, fk_x_device) != CUFFT_SUCCESS){
		printf("CUFFT error: ExecR2C Forward failed (fx)\n");
		return 0;	
	}
	if (cufftExecR2C(plan, fy_device, fk_y_device) != CUFFT_SUCCESS){
		printf("CUFFT error: ExecR2C Forward failed (fy)\n");
		return 0;	
	}
	if (cufftExecR2C(plan, fz_device, fk_z_device) != CUFFT_SUCCESS){
		printf("CUFFT error: ExecR2C Forward failed (fz)\n");
		return 0;	
	}

	/* Print FFT result */
	// copy_to_host<cufftComplex>(fk_x_device, fk_x_host, FFT_GRID_SIZE);
	// copy_to_host<cufftComplex>(fk_y_device, fk_y_host, FFT_GRID_SIZE);
	// copy_to_host<cufftComplex>(fk_z_device, fk_z_host, FFT_GRID_SIZE);
	// print_host_data_complex_3D_indexstyle(fk_x_host, fk_y_host, fk_z_host);



	///////////////////////////////////////////////////////////////////////////////
	// Solve for the flow
	///////////////////////////////////////////////////////////////////////////////
	cufcm_flow_solve<<<num_thread_blocks, THREADS_PER_BLOCK>>>(fk_x_device, fk_y_device, fk_z_device,
															   uk_x_device, uk_y_device, uk_z_device,
															   q_device, qpad_device, qsq_device, qpadsq_device);
															   
	/* Print Fourier flow result */
	// copy_to_host<cufftComplex>(uk_x_device, uk_x_host, FFT_GRID_SIZE);
	// copy_to_host<cufftComplex>(uk_y_device, uk_y_host, FFT_GRID_SIZE);
	// copy_to_host<cufftComplex>(uk_z_device, uk_z_host, FFT_GRID_SIZE);
	// print_host_data_complex_3D_indexstyle(uk_x_host, uk_y_host, uk_z_host);


	///////////////////////////////////////////////////////////////////////////////
	// IFFT
	///////////////////////////////////////////////////////////////////////////////
	if (cufftExecC2R(iplan, uk_x_device, ux_device) != CUFFT_SUCCESS){
		printf("CUFFT error: ExecR2C Backward failed (fx)\n");
		return 0;	
	}
	if (cufftExecC2R(iplan, uk_y_device, uy_device) != CUFFT_SUCCESS){
		printf("CUFFT error: ExecR2C Backward failed (fy)\n");
		return 0;	
	}
	if (cufftExecC2R(iplan, uk_z_device, uz_device) != CUFFT_SUCCESS){
		printf("CUFFT error: ExecC2R Backward failed (fz)\n");
		return 0;	
	}

	/* Normalise the result after IFFT */
	// normalise_array<<<num_thread_blocks, THREADS_PER_BLOCK>>>(ux_device, uy_device, uz_device);

	/* Print IFFT result */
	// copy_to_host<cufftReal>(ux_device, ux_host, GRID_SIZE);
	// copy_to_host<cufftReal>(uy_device, uy_host, GRID_SIZE);
	// copy_to_host<cufftReal>(uz_device, uz_host, GRID_SIZE);
	// print_host_data_real_3D_flat<cufftReal>(ux_host, NX, 1);
	// print_host_data_real_3D_indexstyle(ux_host, uy_host, uz_host);



	///////////////////////////////////////////////////////////////////////////////
	// Gathering
	///////////////////////////////////////////////////////////////////////////////


	

	///////////////////////////////////////////////////////////////////////////////
	// Finish
	///////////////////////////////////////////////////////////////////////////////
	cufftDestroy(plan);
	cudaFree(fx_device); cudaFree(fy_device); cudaFree(fz_device); 
	cudaFree(fk_x_device); cudaFree(fk_y_device); cudaFree(fk_z_device);
	cudaFree(ux_device); cudaFree(uy_device); cudaFree(uz_device); 
	cudaFree(uk_x_device); cudaFree(uk_y_device); cudaFree(uk_z_device);
	cudaFree(Y_device);
	cudaFree(F_device);
	cudaFree(T_device);
	cudaFree(V_device);
	cudaFree(W_device);
	cudaFree(GA_device);

	cudaFree(gaussx_device);
	cudaFree(gaussy_device);
	cudaFree(gaussz_device);
	cudaFree(grad_gaussx_dip_device);
	cudaFree(grad_gaussy_dip_device);
	cudaFree(grad_gaussz_dip_device);
	cudaFree(gaussgrid_device);
	cudaFree(xdis_device);
	cudaFree(ydis_device);
	cudaFree(zdis_device);
	cudaFree(indx_device);
	cudaFree(indy_device);
	cudaFree(indz_device);

	cudaFree(q_device);
	cudaFree(qpad_device);
	cudaFree(qsq_device);
	cudaFree(qpadsq_device);

	return 0;
}

