#pragma once
#include "config.hpp"

__device__ __host__
int icell(int M, int x, int y, int z, uint64_t (*f)(unsigned int, unsigned int, unsigned int, int));

__host__ __device__
uint64_t linear_encode(unsigned int xi, unsigned int yi, unsigned int zi, int M);

__device__ __host__
void bulkmap_loop(int* map, int M, uint64_t (*f)(unsigned int, unsigned int, unsigned int, int));

__global__
void create_hash_gpu(int *hash, Real *Y, int N, Real dx, int M);

__global__
void particle_index_range(int *particle_index, int N);

template <typename T>
__global__
void copy_device(T *from, T *to, int L){
    const int index = threadIdx.x + blockIdx.x*blockDim.x;
    const int stride = blockDim.x*gridDim.x;

    for(int np = index; np < L; np += stride){
        to[np] = from[np];
    }
    
    return;
}

template <typename T>
__global__
void sort_3d_by_index(int *pindex, T *in, T *aux, int L){
    const int index = threadIdx.x + blockIdx.x*blockDim.x;
    const int stride = blockDim.x*gridDim.x;

    for(int np = index; np < L; np+=stride){

        in[3*np + 0] = aux[3*pindex[np] + 0];
        in[3*np + 1] = aux[3*pindex[np] + 1];
        in[3*np + 2] = aux[3*pindex[np] + 2];
    }
    
    return;
}

// void sort_index_by_key(int *key, int *index, int *key_buf, int *index_buf, int N);
void sort_index_by_key(int *key, int *index, int *key_buf, int *index_buf, int N);

__global__
void create_cell_list(const int *particle_cellindex, int *cell_start, int *cell_end, int N);