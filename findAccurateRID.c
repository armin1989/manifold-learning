#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "functions.h"


void findAccurateRID(double *refPatch, double refAngle, double **pathces, double *angles, 
            int NN, int P, double h, double *distances)
{
    double **refImage, **currImage;
    double angle, d;
    int i;
    int center = (P - 1) / 2 + 1;
    
    createMatrix(&refImage, P, P);
    reshape(refImage, refPatch, P, P);
    createMatrix(&currImage, P, P);
    
    for(i = 0; i < NN; i++)
    {
        // have to reshape patch vectors to patch matrices for rotation
        reshape(currImage, pathces[i], P, P);
        angle = (angles[i] - refAngle) * 180 / PI; 
        // finding RID using exhaustive search, reference angle is midpoint 
        // of search interval, we search from angle - 30 to angle + 30 with
        // increments of 5 defrees
        d = findRIDexhaustive(refImage, currImage, angle, P);
        distances[i] = exp(-pow(d, 2) / h);        
    }
    freeMatrix(refImage, P, P);
    freeMatrix(currImage, P, P);
}
                    


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* This function finds the accurate RID distance between a reference 
     * patch and neighbouring pathces. This is done through exhaustive search,
     * reference patch is rotated with fixed increments of angle and distnaces
     * is evaluated. Min of all calculated distances is taken as RID.
     *  
     * Inputs :
     *      0 : the reference patch with dimesnions (P x P) x 1
     *      1 : angle of the reference patch
     *      2 : matrix of neighbour patches NN x (P x P)
     *      3 : vector of angles of each patch from SIFT NN x 1
     *      4 : number of neighbours NN
     *      5 : width of the Gaussian kernel : h
     *
     * Output :
     *      0 : A NN x 1 double array of distances
     
     */
    double *refPatch, **patches, *angles, **test, d;
    double *input3, *input1, refAngle;
    int numPatches, P, patchRadius, NN, count = 0;
    double *output0,  *dist;
    double h;
    int **idx;
    size_t outputDims[1];
    /* connecting to input and output from MATLAB */
    refPatch = mxGetPr(prhs[0]);
    refAngle = mxGetScalar(prhs[1]);
    input1 = mxGetPr(prhs[2]);
    angles = mxGetPr(prhs[3]);
    NN = mxGetScalar(prhs[4]);
    h = mxGetScalar(prhs[5]);
    
    P = sqrt(mxGetM(prhs[0]));
    
    outputDims[0] = (size_t)NN;
    //printf("Got %d patches of size %d, h is %lf\n", outputDims[0], P, h);
    
    
    plhs[0] = mxCreateNumericArray(1, outputDims, mxDOUBLE_CLASS, mxREAL);
    dist = (double *)mxGetPr(plhs[0]);
     
    /* converting the points array to standard C matrices */
    createMatrix(&patches, NN, P * P);
    getMatrix(patches, NN, P * P, input1);

    
    /* finding RID */
    findAccurateRID(refPatch, refAngle, patches, angles, NN, P, h, dist);
     
    
    /* freeing dynamically allocated matrices */
    freeMatrix(patches, NN, P * P);

    return;            
}

