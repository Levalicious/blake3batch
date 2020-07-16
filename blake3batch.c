#include "blake3batch.h"
#include <CL/cl.h>

#include <stdio.h>

#define MAX_SOURCE_SIZE (0x100000LU)

#define GSIZE (32LU)

static char* readFile(const char* path, size_t* len) {
    FILE* file = fopen(path, "rb");
    if (file == NULL) {
        fprintf(stderr, "Could not open file \"%s\".\n", path);
        exit(-1);
    }

    fseek(file, 0L, SEEK_END);
    size_t fileSize = (ftell(file) < MAX_SOURCE_SIZE) ? ftell(file) : MAX_SOURCE_SIZE;
    rewind(file);

    char* buffer = (char*) malloc(fileSize + 1);
    if (buffer == NULL) {
        fprintf(stderr, "Not enough memory to read \"%s\".\n", path);
        exit(-1);
    }

    size_t bytesRead = fread(buffer, sizeof(char), fileSize, file);
    if (bytesRead < fileSize) {
        fprintf(stderr, "Could not read file \"%s\".\n", path);
        exit(-1);
    }

    buffer[bytesRead] = '\0';

    *len = fileSize;

    fclose(file);
    return buffer;
}

unsigned char* blake3batch(unsigned char* input, const unsigned int n, const unsigned int size) {
    size_t source_size;

    char* source_str = readFile("../kernels/vector_blake3_kernel.cl", &source_size);

    cl_platform_id platform_id = NULL;
    cl_device_id device_id = NULL;
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    ret = clGetDeviceIDs( platform_id, CL_DEVICE_TYPE_DEFAULT, 1, &device_id, &ret_num_devices);

    cl_context context = clCreateContext( NULL, 1, &device_id, NULL, NULL, &ret);
    if (ret != CL_SUCCESS) return NULL;

    cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &ret);
    if (ret != CL_SUCCESS) return NULL;

    cl_mem inMem = clCreateBuffer(context, CL_MEM_READ_ONLY, (size_t) (n * size), NULL, &ret);
    cl_mem outMem = clCreateBuffer(context, CL_MEM_WRITE_ONLY, (size_t) (n * size), NULL, &ret);
    if (ret == CL_MEM_OBJECT_ALLOCATION_FAILURE) return NULL;
    if (ret == CL_MEM_OBJECT_ALLOCATION_FAILURE) return NULL;

    ret = clEnqueueWriteBuffer(command_queue, inMem, CL_TRUE, 0, n * size, input, 0, NULL, NULL);
    if (ret != CL_SUCCESS) return NULL;
    cl_program program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&source_size, &ret);
    if (ret != CL_SUCCESS) return NULL;
    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    if (ret != CL_SUCCESS) return NULL;
    cl_kernel kernel = clCreateKernel(program, "vector_blake3", &ret);

    cl_uint inputSize = 32;
    ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&inMem);
    ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&outMem);
    ret = clSetKernelArg(kernel, 2, sizeof(cl_uint), (void*) &inputSize);

    if (ret != CL_SUCCESS) return NULL;

    cl_build_status blstats = 0;
    size_t lafbasze = 0;
    ret = clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_STATUS, 65536, &blstats, &lafbasze);
    if (ret != CL_SUCCESS) return NULL;
    if (blstats != CL_BUILD_SUCCESS) {
        ret = clFlush(command_queue);
        ret = clFinish(command_queue);
        ret = clReleaseKernel(kernel);
        ret = clReleaseProgram(program);
        ret = clReleaseMemObject(inMem);
        ret = clReleaseMemObject(outMem);
        ret = clReleaseCommandQueue(command_queue);
        ret = clReleaseContext(context);
        return NULL;
    }

    /*
     * Solely for debugging
    char* mbdrdsf = calloc(65536, 1);
    size_t lafbasze = 0;
    ret = clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, 65536, mbdrdsf, &lafbasze);
    mbdrdsf[lafbasze] = '\0';
    printf("> %s %lu\n", mbdrdsf, lafbasze);
    free(mbdrdsf);
     */

    size_t global_item_size = n;
    size_t local_item_size = GSIZE;
    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    if (ret != CL_SUCCESS) return NULL;

    unsigned char *out = (unsigned char*)malloc(32 * n);
    ret = clEnqueueReadBuffer(command_queue, outMem, CL_TRUE, 0, n * 32, out, 0, NULL, NULL);
    if (ret != CL_SUCCESS) return NULL;

    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);
    ret = clReleaseMemObject(inMem);
    ret = clReleaseMemObject(outMem);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);
    if (ret != CL_SUCCESS) return NULL;
    return out;
}
