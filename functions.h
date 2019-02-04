#include <math.h>

const double PI = 3.14159265358979323846;


void reshape(double **result, double *array, int m, int n)
{
    /* reshape the input array of size m * n x 1 to an m x n matrix */
    int i = 0; 
    for(i = 0; i < m * n; i++)
    {
        result[i % n][i / n] = array[i];
    }
    
}

void getMatrix(double **result, int m, int n, double *matlabInput)
{
    int i, j, count = 0;
    
    for(i = 0; i < n; i++)
    {
        for(j = 0; j < m; j++)
        {
            result[j][i] = *(matlabInput + count);
            /*printf("%lf ,", *(input + count));*/
            count++;           
        }
    }
}

void getIntMatrix(int **result, int m, int n, int *matlabInput)
{
    int i, j, count = 0;
    
    for(i = 0; i < n; i++)
    {
        for(j = 0; j < m; j++)
        {
            result[j][i] = *(matlabInput + count);
            /*printf("%lf ,", *(input + count));*/
            count++;           
        }
    }
}

void setMatrix(double **result, int m, int n, double *matlabOutput)
{
    int i, j, count = 0;
    
    for(i = 0; i < n; i++)
    {
        for(j = 0; j < m; j++)
        {
            *(matlabOutput + count) = result[j][i];
            /*printf("%lf ,", *(input + count));*/
            count++;           
        }
    }
}

void setFloatMatrix(float **result, int m, int n, float *matlabOutput)
{
    int i, j, count = 0;
    
    for(i = 0; i < n; i++)
    {
        for(j = 0; j < m; j++)
        {
            *(matlabOutput + count) = result[j][i];
            /*printf("%lf ,", *(input + count));*/
            count++;           
        }
    }
}

void setIntMatrix(int **result, int m, int n, int *matlabOutput)
{
    int i, j, count = 0;
    
    for(i = 0; i < n; i++)
    {
        for(j = 0; j < m; j++)
        {
            *(matlabOutput + count) = result[j][i];
            /*printf("%lf ,", *(input + count));*/
            count++;           
        }
    }
}


double vecNorm(double *ar, double *ai, int n)
{
    double result = 0;
    int i;
    for(i = 0; i < n ; i++)
    {
        result += pow(ar[i] - ai[i], 2);
    }
    return sqrt(result);
}



void printArray(double *sr, int T)
{
    int i;
    for(i = 0; i < T; i++)
    {
        printf("%lf ", sr[i]);
    }
    printf("\n");
}

void printIntArray(int *sr, int T)
{
    int i;
    for(i = 0; i < T; i++)
    {
        printf("%d ", sr[i]);
    }
    printf("\n");
}

void createMatrix(double ***A, int m, int n)
{
    /* creates an m by n matrix of doubles in location A */
    int i, j;
    (*A) = (double **)malloc(sizeof(double *) * m);
    for(i = 0; i < m; i++)
    {
        (*A)[i] = (double *)malloc(sizeof(double) * n);
        for(j = 0; j < n; j++)
            (*A)[i][j] = 0;
    }
}

void createFloatMatrix(float ***A, int m, int n)
{
    /* creates an m by n matrix of doubles in location A */
    int i, j;
    (*A) = (float **)malloc(sizeof(float *) * m);
    for(i = 0; i < m; i++)
    {
        (*A)[i] = (float *)malloc(sizeof(float) * n);
        for(j = 0; j < n; j++)
            (*A)[i][j] = 0;
    }
}

void createIntMatrix(int ***A, int m, int n)
{
    /* creates an m by n matrix of doubles in location A */
    int i, j;
    (*A) = (int **)malloc(sizeof(int *) * m);
    for(i = 0; i < m; i++)
    {
        (*A)[i] = (int *)malloc(sizeof(int) * n);
        for(j = 0; j < n; j++)
            (*A)[i][j] = 0;
    }
}

void freeMatrix(double **A, int m, int n)
{
    /* frees an m by n matrix that is dynamically allocated */
    int i, j;
    for(i = 0; i < m; i++)
    {
        free(A[i]);
    }
    free(A);
}

void freeFloatMatrix(float **A, int m, int n)
{
    /* frees an m by n matrix that is dynamically allocated */
    int i, j;
    for(i = 0; i < m; i++)
    {
        free(A[i]);
    }
    free(A);
}

void freeIntMatrix(int **A, int m, int n)
{
    /* frees an m by n matrix that is dynamically allocated */
    int i, j;
    for(i = 0; i < m; i++)
    {
        free(A[i]);
    }
    free(A);
}

void printMatrix(double **A, int m, int n)
{
    /* frees an m by n matrix that is dynamically allocated */
    int i, j;
    for(i = 0; i < m; i++)
    {
        for(j = 0; j < n; j++)
            printf("%lf ", A[i][j]);
        printf("\n");
    }
}

void rotate(double **dest, double **source, double angle, int m, int n)
{
    /* to rotate the given input double patch by angle and store the result
     * in the output array, assumption is that input is a grayscale image */
   
	int width = n;
	int height = m;
	int i, N;
	const double rad = (double)((angle*PI)/180.0);
	const double ca = (double) cos(rad);
    const double sa = (double) sin(rad);
	const float 
	  ux  = (float)(fabs(width * ca)),  uy  = (float)(fabs(width * sa)),
	  vx  = (float)(fabs(height * sa)), vy  = (float)(fabs(height * ca)),
	  w2  = 0.5f*width,           h2  = 0.5f*height,
	  dw2 = 0.5f*(ux+vx),         dh2 = 0.5f*(uy+vy); /* dw2, dh2 are the dimentions for rotated image without cropping. */

	int X,Y; /* Locations in the source matrix */
	int x,y,color; /* For counters */
	
    for(y=0; y < height; y++)
    {
        for(x=0; x < width; x++)
        {
            X=(int)(w2 + (x - w2) * ca + (y - h2) * sa + 0.5); /* Source X */
            Y=(int)(h2 - (x - w2) * sa + (y - h2) * ca + 0.5); /*  Source Y*/
            /*X=(int)(w2 + (x-dw2)*ca + (y-dh2)*sa); // Source X- without cropping
            Y=(int)(h2 - (x-dw2)*sa + (y-dh2)*ca); // Source Y- without cropping */

            dest[x][y] = (X<0 || Y<0 || X>=width || Y>=height) ? 0 : source[X][Y];
        }
    }
}

double diffNorm(double **p1, double **p2, int m , int n)
{
    /* find the matrix Frobenius norm of p1 - p2 */
    double norm = 0, temp;
    int i, j;
    for(i = 0; i < m; i++)
        for(j = 0; j < n; j++)
        {
            norm += pow(p1[i][j] - p2[i][j], 2);
        }
    return sqrt(norm);
}

double findRID(double **p1, double **p2, double a, int size)
{
    /* find the RID distance between p1 and p2 by rotating p2 by a degrees 
     * and finding the norm of the result */
    double **rotated;
    double dist = 0;
    createMatrix(&rotated, size, size);
    rotate(rotated, p2, a, size, size);
    dist = diffNorm(p1, rotated, size, size);
    freeMatrix(rotated, size, size);
    return dist;
    
}

double findRIDexhaustive(double **p1, double **p2, double a, int size)
{
    /* find the RID distance between p1 and p2 by rotating p2 exhaustively 
     * between a - 30 and a + 30 and finding the norm of the result */
    double **rotated;
    double dist = 0;
    double minDist = diffNorm(p1, p2, size, size);
    double angle;
    createMatrix(&rotated, size, size);
    
    for(angle = a - 30; angle < a + 30; angle += 5)
    {
        rotate(rotated, p2, angle, size, size);
        dist = diffNorm(p1, rotated, size, size);
        if(dist < minDist)
            minDist = dist;
    }
    
    freeMatrix(rotated, size, size);
    return minDist;
    
}


double findD(double **p1, double **p2, int size)
{
    /* find the RID distance between p1 and p2 by rotating p2 by a degrees 
     * and finding the norm of the result */
    double dist = 0;
    int i , j;
    for(i = 0; i < size; i++)
       for(j = 0; j < size; j++)
        {
            dist += pow(p1[i][j] - p2[i][j], 2);
        }
    return sqrt(dist);
}


void getPatch(double **p, double **img, int x, int y , int P)
{
    /* to get the patch located at (x, y) with a radius of P from the image
     * and store it in p */
    int i, j;
    int size = 2 * P + 1;
    for(i = 0; i < size; i++)
        for(j = 0; j < size; j++)
            p[i][j] = img[x - P + i][y - P + j];
    
}


void insertAndSort(double *array, int *idx, double new, int currIdx, int kNN)
{
    /* inserts a new element in the sorted array. The size of the array should
     * be at max kNN. currIdx is in fact the index of the current patch */
    int size = (currIdx + 1) < kNN ? (currIdx + 1) : kNN;
    int i, j;
    /* finding the location to insert the new element, assuming array is sorted
     * in increasing order */
        
    for(i = 0; i < size; i++)
    {
        if(array[i] < new)
            break;
    }
    
    
    if( i == size)
    {
        array[size - 1] = new;
        idx[size - 1] = currIdx;
    }
    else{
        /* shitfing everything from i to size by one and inserting new element */
        for(j = size - 1; j > i; j--)
        {
            array[j] = array[j - 1];
            idx[j] = idx[j - 1];
        }    
        array[i] = new;
        idx[i] = currIdx;    
    }
}