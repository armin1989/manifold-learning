#include "mex.h"
#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "functions.h"

void findDistances(double *distances, double **points, int m, int n, int refIdx)
{
    /* This function finds the pairwise distances of the points. 
     * We have m points in the n-D space */
    int i, j;
    for(i = 0; i < m; i++)
        distances[i] = vecNorm(points[i], points[refIdx], n);   
    
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* This finds the diffusion distances of a given patchIdx and the 
     *  rest of embedded points. 
     * Inputs :
     *      0 : embedded points
     *      1 : number of points
     *      2 : dimension of embedded points
     *      3 : index of reference patch
     *
     * Output :
     *      0 : 1 x number of points double array of distances
     
     */
    double **points;
    double *distances;
    double *input;
    int numPoints, embedDim, i, j, count = 0, refIdx;
    int outputDims[1];
    float *output;
    
    /* connecting to input and output from MATLAB */
    input = mxGetPr(prhs[0]);
    numPoints = mxGetScalar(prhs[1]);
    embedDim = mxGetScalar(prhs[2]);
    refIdx = mxGetScalar(prhs[3]);
    
    outputDims[0] = numPoints;
    
    plhs[0] = mxCreateNumericArray(1, outputDims, mxDOUBLE_CLASS, mxREAL);
    /*plhs[0] = mxCreateDoubleMatrix(numPoints, numPoints, mxREAL);*/
    distances = mxGetPr(plhs[0]);
    
    
    
    /* converting the points array to standard C matrices */
    createMatrix(&points, numPoints, embedDim);
    getMatrix(points, numPoints, embedDim, input);     
    /*printMatrix(points, numPoints, embedDim);*/
    
    /* finding pairwise distances */
    /*createFloatMatrix(&distances, numPoints, numPoints);*/
    findDistances(distances, points, numPoints, embedDim, refIdx);
    /*setFloatMatrix(distances, numPoints, numPoints, output);*/
    
    freeMatrix(points, numPoints, embedDim);
    /*freeFloatMatrix(distances, numPoints, numPoints);*/
    return;            
/* code here */
}


