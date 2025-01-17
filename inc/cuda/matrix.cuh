#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
//__device__ void matrix_init(matrix* m, int dim, float fill_data);
//__device__ void mat_init(matrix* m, float fill_data);
//__device__ void matrix_set_diagonal(matrix* m, float fill_data);
//__device__ inline void matrix_set_element(matrix* m, int dim, int x, int y, float fill_data);
//__device__ inline void matrix_set_element_tri(matrix* m, int x, int y, float fill_data);
//__device__ inline int tri_index(int n, int i, int j);
//__device__ inline int index_permissive(const matrix* m, int i, int j);

__device__ void matrix_init(matrix* m, int dim, float fill_data, int threadNumInBlock, int threadsPerBlock) {
	m->dim = dim;
	
	if ((dim * (dim + 1) / 2) > MAX_HESSIAN_MATRIX_SIZE)printf("\nnmatrix: matrix_init() ERROR!");
	
	for (int i = threadNumInBlock;
		i < MAX_HESSIAN_MATRIX_SIZE;
		i = i + threadsPerBlock
		) 
	{
		//m->data = (double*)((dim * (dim + 1) / 2) * sizeof(float)); // symmetric matrix
		if (i < (dim * (dim + 1) / 2))
		{
			m->data[i] = fill_data;
		}
		else
		{
			m->data[i] = 0;// Others will be 0
		}
	}
}

// as rugular 3x3 matrix
__device__ void mat_init(matrix* m, float fill_data) {
	m->dim = 3; // fixed to 3x3 matrix
	if (9 > MAX_HESSIAN_MATRIX_SIZE)printf("\nnmatrix: mat_init() ERROR!");
	for (int i = 0; i < 9; i++)m->data[i] = fill_data;
}


__device__ void matrix_set_diagonal(matrix* m, float fill_data, int threadNumInBlock, int threadsPerBlock) {
	for (int i = threadNumInBlock;
		i < m->dim;
		i = i + threadsPerBlock
		)
	{
		m->data[i + i * (i + 1) / 2] = fill_data;
	}
	__syncthreads();
}

// as rugular matrix
__device__ inline void matrix_set_element(matrix* m, int dim, int x, int y, float fill_data) {
	m->data[x + y * dim] = fill_data;
}

__device__ inline void matrix_set_element_tri(matrix* m, int x, int y, float fill_data) {
	m->data[x + y * (y + 1) / 2] = fill_data;
}
__device__ inline int tri_index(int n, int i, int j) {
	if (j >= n || i > j)printf("\nmatrix: tri_index ERROR!");
	return i + j * (j + 1) / 2;
}

__device__ inline int index_permissive(const matrix* m, int i, int j) {
	return (i < j) ? tri_index(m->dim, i, j) : tri_index(m->dim, j, i);
}
