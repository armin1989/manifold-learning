#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "functions.h"

int findNeighborIdx(int x1, int y1, int x2, int y2, int window, int r, int c);

void createAffinity(float **W, int **idx, double **img, double **angles, 
                    int r, int c, int P, int window)
{
    int i, j, p1Idx, p2Idx, x1, y1, x2, y2, x, y;
    int xmin, xmax, ymin, ymax, k, k2;
    int i1, j1, i2, j2, count;
    int size = 2 * P + 1;
    int num = r * c;  // overall number of patches
    int kNN = (2 * window + 1) * (2 * window + 1);  // number of neighbours expecting to look for
    double **p1, **p2;
    double a1, a2, angle, d1, d2;
    double RID, d;
    int center = (size - 1) / 2 + 1;
    createMatrix(&p1, size, size);
    createMatrix(&p2, size, size);

    for(i = 0; i < num; i++)
    {    
        /* getting the reference patch */
        y1 = i % c;
        x1 = i / c;    
        getPatch(p1, img, x1 + P, y1 + P, P);
        a1 = angles[i][0];
        /* counter to count the neighbours */
        count = 0;
        
        /* finding the regions of the neighbours */        
        xmin = -window + x1;
        xmax =  window + x1;
        ymin = -window + y1;
        ymax = window + y1;
        
        for(x = xmin; x <= xmax; x++)
        {
            for(y = ymin; y <= ymax; y++)
            {
                 x2 = x;
                 y2 = y;
                 // finding index of neigbhouring patch in patch space
                 k = findNeighborIdx(x1, y1, x2, y2, window, r, c);
                 
                 // wrapping around the image for pathces closer to edges
                 if(x2 < 0)
                    x2 += c;
                if(x2 >= c)
                    x2 -= c;
                if(y2 < 0)
                    y2 += r;
                if(y2 >= r)
                    y2 -= r;
                          
                // since closest neighbours are symmetric, we can use this
                // info twice (i, j), (j, i)
                k2 = findNeighborIdx(x2, y2, x1, y1, window, r, c);
                j = (x2) * c + (y2);
                
                if(j < i)
                    continue;
                    
                getPatch(p2, img, x2 + P, y2 + P, P);
                a2 = angles[j][0];
                /* the realtive angle between the patches */
                angle = (a2 - a1) / PI * 180;
                
                // alligns patches according to relative angle and finds RID
                d = findRID(p1, p2, angle, size);
                
                
                W[i][k] = (float)d;
                idx[i][k] = j;

                W[j][k2] = (float)d;
                idx[j][k2] = i;
            }
        } 
    }
    // free dynamically allocated patch matrices   
    freeMatrix(p1, size, size);
    freeMatrix(p2, size, size);
}
                    


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* This creates the affinity matrix between each pair of patches 
     * Inputs :
     *      0 : matrix of padded image with size (2P + r) x (2P + c)
     *      1 : matrix of angles (numPatches x 1)
     *      2 : P : patch radius
     *      3 : window : width of the search window
     *      4 : r : height of the image
     *      5 : c : width of the image
     *
     * Output :
     *      0 : A numPatches x kNN double array of distances
     *      1 : A numPatches x kNN matrix of indices of nearest neighbours
     
     */
    double **img, **angles, **patch;
    double *input0, *input1, *input6;
    int numPatches, P, patchSize, window, kNN, r, c, count = 0;
    float *output0, **dist;
    int *output1;
    double h;
    int **idx;
    size_t outputDims[2];
    /* connecting to input and output from MATLAB */
    input0 = mxGetPr(prhs[0]);
    input1 = mxGetPr(prhs[1]);
    P = mxGetScalar(prhs[2]);
    window = mxGetScalar(prhs[3]);
    r = mxGetScalar(prhs[4]);
    c = mxGetScalar(prhs[5]);         
    
    kNN = (2 * window + 1) * (2 * window + 1);
    numPatches = r * c;
    patchSize = 2 * P + 1;
    outputDims[0] = (size_t) numPatches;
    outputDims[1] = (size_t) kNN;
    
    /*printf("Got %d img of size %d\n", numPatches, patchSize);*/
    
    plhs[0] = mxCreateNumericArray(2, outputDims, mxSINGLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, outputDims, mxINT32_CLASS, mxREAL);
    output0 = (float *)mxGetPr(plhs[0]);
    output1 = mxGetData(plhs[1]);
    
    
    /* converting the points array to standard C matrices */
    createMatrix(&img, r + 2 * P, c + 2 * P);
    createMatrix(&angles, numPatches, 1);
    getMatrix(img, r + 2 * P, c + 2 * P, input0);
    getMatrix(angles, numPatches, 1, input1);
    
    /* creating output arrays */
    createFloatMatrix(&dist, numPatches, kNN);
    createIntMatrix(&idx, numPatches, kNN);
    
    createAffinity(dist, idx, img, angles, r, c, P, window);
    setFloatMatrix(dist, numPatches, kNN, output0);
    setIntMatrix(idx, numPatches, kNN, output1);
    
    /* freeing dynamically allocated matrices */
    freeFloatMatrix(dist, numPatches, kNN);
    freeIntMatrix(idx, numPatches, kNN);
    freeMatrix(img, r + 2 * P, c + 2 * P);
    freeMatrix(angles, numPatches, 1);
    return;            
}

int findNeighborIdx(int x1, int y1, int x2, int y2, int window, int r, int c)
{
    int xmin = x1 - window;
    int ymin = y1 - window;
    int xmax =  window + x1;
    int ymax = window + y1;
    
    if(fabs(x2 - x1) > 2 * window)
    {
        if(xmin < 0)
            x2 -= c;
        else
            x2 += c;
    }
    
    if(fabs(y2 - y1) > 2 * window)
    {
        if(ymin < 0)
            y2 -= r;
        else
            y2 += r;
    }
    return (x2 - xmin) * (2 * window + 1) + (y2 - ymin);
       
}

