#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "functions.h"


double sigma = 0.1;


void createAffinity(float **W, int **idx, double **img, 
                    int r, int c, int P, int window, double h)
{
    int i, j, p1Idx, p2Idx, x1, y1, x2, y2;
    int xmin, xmax, ymin, ymax;
    int i1, j1, i2, j2, count;
    int size = 2 * P + 1;
    int num = r * c;
    int kNN = (2 * window) * (2 * window);
    /*double *temp_dist;*/
    double **p1, **p2;
    double a1, a2, angle, d1, d2;
    double RID, d;
    int center = (size - 1) / 2 + 1;
    createMatrix(&p1, size, size);
    createMatrix(&p2, size, size);
    
    for(i = 0; i < num; i++)
    {
        
        /* getting the reference patch */
        y1 = i % c + P;
        x1 = i / c + P;    
        getPatch(p1, img, x1, y1, P);
        /* counter to count the neighbours */
        count = 0;
        
        /* finding the regions of the neighbours */
        xmin = (0 > -window + x1 - P ? 0 : -window + x1 - P) + P;
        xmax = (c - 1 < window + x1 - P - 1 ? c - 1 : window + x1 - P - 1) + P;
        ymin = (0 > -window + y1 - P ? 0 : -window + y1 - P) + P;
        ymax = (r - 1 < window + y1 - P - 1 ? r - 1 : window + y1 - P - 1) + P;
        
        for(x2 = xmin; x2 <= xmax; x2++)
        {
            for(y2 = ymin; y2 <= ymax; y2++)
            {
                j = (x2 - P) * c + (y2 - P);
                getPatch(p2, img, x2, y2, P);
                d1 = findD(p1, p2, size);
                d = exp(-pow(d1, 2) / h);
                if(count < kNN){
                    W[i][count] = (float)d;
                    idx[i][count] = j;
                    count++;
                }
            }
        }
 
        
    }
    
    
    freeMatrix(p1, size, size);
    freeMatrix(p2, size, size);
}
                    


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* This creates the affinity matrix between each pair of patches 
     * Inputs :
     *      0 : matrix of padded image with size (2P + r) x (2P + c)
     *      1 : P : patch radius
     *      2 : window : width of the search window
     *      3 : r : height of the image
     *      4 : c : width of the image
     *      5 : h : width of kernel
     *
     * Output :
     *      0 : A numPatches x kNN double array of distances
     *      1 : A numPatches x kNN matrix of indices of nearest neighbours
     
     */
    double **img, **patch;
    double *input0, *input1, *input6;
    int numPatches, P, patchSize, window, kNN, r, c, count = 0;
    float *output0, **dist;
    int *output1;
    double h;
    int **idx;
    int outputDims[2];
    /* connecting to input and output from MATLAB */
    input0 = mxGetPr(prhs[0]);
    P = mxGetScalar(prhs[1]);
    window = mxGetScalar(prhs[2]);
    r = mxGetScalar(prhs[3]);
    c = mxGetScalar(prhs[4]);
    h = mxGetScalar(prhs[5]);
    
    kNN = (2 * window) * (2 * window);
    numPatches = r * c;
    patchSize = 2 * P + 1;
    outputDims[0] = numPatches;
    outputDims[1] = kNN;
    /*printf("Got %d img of size %d\n", numPatches, patchSize);*/
    
    plhs[0] = mxCreateNumericArray(2, outputDims, mxSINGLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, outputDims, mxINT32_CLASS, mxREAL);
    output0 = (float *)mxGetPr(plhs[0]);
    output1 = mxGetData(plhs[1]);
    
    
    /* converting the points array to standard C matrices */
    createMatrix(&img, r + 2 * P, c + 2 * P);
    getMatrix(img, r + 2 * P, c + 2 * P, input0);
    
    /* creating output arrays */
    createFloatMatrix(&dist, numPatches, kNN);
    createIntMatrix(&idx, numPatches, kNN);
    
    createAffinity(dist, idx, img, r, c, P, window, h);
    setFloatMatrix(dist, numPatches, kNN, output0);
    setIntMatrix(idx, numPatches, kNN, output1);
    
    /* freeing dynamically allocated matrices */
    freeFloatMatrix(dist, numPatches, kNN);
    freeIntMatrix(idx, numPatches, kNN);
    freeMatrix(img, r + 2 * P, c + 2 * P);
    return;            
}

