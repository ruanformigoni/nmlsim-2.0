extern"C" {
void demag3D3(double *px, double *py, double *th, double *d);
}

extern"C" {
void dipolar3D3(
        double *ppx_j,
        double *ppy_j,
        double *th_j,
        double *ddo_j,
        double *ppx_k,
        double *ppy_k,
        double *th_k,
        double *ddo_k,
        double *pc
        );
}