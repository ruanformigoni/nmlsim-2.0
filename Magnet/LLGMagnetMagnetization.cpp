/*
	PROGRAMA DE CALCULO DO TENSOR DESMAGNETIZACAO DE
	POLIGONOS IRREGULARES (SLANTED)

	px(1),py(1): coordenadas do canto superior esquerdo (nm) em relação ao centro da partícula
	px(2),py(2): coordenadas do canto superior direito  (nm) em relação ao centro da partícula
	px(3),py(3): coordenadas do canto inferior direito  (nm) em relação ao centro da partícula
	px(4),py(4): coordenadas do canto inferior esquerdo (nm) em relação ao centro da partícula
	t	   : espessura (nm)

	*************** RESTRICAO ****************
	-------> px(1) e px(4) DEVEM ser iguais
	-------> px(2) e px(3) DEVEM ser iguais
	******************************************

	Matriz de saida (line 228-238):
	d1, d2, d3
	d4, d5, d6
	d7, d8, d9

	OBS.: OS FATORES DE DESMAGNETIZACAO (variable tensor line 309) SAO OBTIDOS FAZENDO

	      D11=d1/(4*Pi*V), D12=d2/(4*Pi*V), D13=d3/(4*Pi*V)
	      D21=d4/(4*Pi*V), D22=d5/(4*Pi*V), D23=d6/(4*Pi*V)
	      D31=d7/(4*Pi*V), D32=d8/(4*Pi*V), D33=d9/(4*Pi*V)

	      ONDE V e DADO EM nm^3

	A energia de desmagnetizacao (eV) e calculada como

	Ud = K/2*(
	          (d1*COS(phi)^2 + d5*SIN(phi)^2 + (d2+d4)*SIN(phi)*COS(phi))*SIN(theta)^2 +
		  ((d3+d7)*COS(phi) + (d6+d8)*SIN(phi))*SIN(theta)*COS(theta) +
	  d9*COS(theta)^2
		 )
	ONDE

	K = mu0*Ms*Ms*JtoeV*ten**(-27)/(four*Pi)
	Ms = 800 kA/m
	mu0 = 4*Pi*10^-7 H/m
	JtoeV = 6.242_lg*ten**(18)
*/

#include "LLGMagnetMagnetization.h"

map<string, double *> LLGMagnetMagnetization::dipBib;
map<string, double **> LLGMagnetMagnetization::demagBib;
map<string, double> LLGMagnetMagnetization::volumeBib;

LLGMagnetMagnetization::LLGMagnetMagnetization(double * px, double * py, double thickness){
    this->px = (double *) malloc(4*sizeof(double));
    this->py = (double *) malloc(4*sizeof(double));
    for(int i=0; i<4; i++){
        this->px[i] = px[i];
        this->py[i] = py[i];
    }
    this->t = thickness;
}

double LLGMagnetMagnetization::frand(double xmin, double xmax) {
    return ((double)rand()/RAND_MAX)*(xmax-xmin)+xmin;
}


double * LLGMagnetMagnetization::frand_xz() {
// input vector is in={xmin,xmax,ymin,ymax,zmin,zmax,xpmin,xpmax,ypmin,ypmax,zmin,zmax}
    static double out[4];
    double in[8] = {-0.5*w, 0.5*w, -0.5*t, 0.5*t, -0.5*w, 0.5*w, -0.5*t, 0.5*t};
    for(int i=0; i<4; i++)
        out[i]=((double)rand()/RAND_MAX)*(in[2*i+1] - in[2*i]) + in[2*i];
    return out;
}


double * LLGMagnetMagnetization::fu(double in[6]) {
 // input vector is  in={x(0),y(1),z(2),xp(3),yp(4),zp(5)}
    static double out[3];
    double den;
    den = pow((in[0] - in[3]) * (in[0] - in[3]) + (in[1] - in[4]) * (in[1] - in[4]) + (in[2] - in[5]) * (in[2] - in[5]), -1.5);
    for(int i=0; i<3; i++)
        *(out+i) = (*(in + i + 3) - *(in + i))*den;
    return out;
}


double LLGMagnetMagnetization::fy(double x, const double ab[2]) {
    return ab[0]*x + ab[1];
}

double * LLGMagnetMagnetization::demag(double * py){
    static double abc_out[18];
    double *abc, a[6]={0}, b[6]={0}, c[6]={0};
    double *xz, x[6], yi[4];
    double yd_x, yu_x, Dy;
    double yd_xp, yu_xp, Dyp;

    double s[6];
    s[0] = w * t * t * (py[1] - py[2]);
    s[1] = w * w * t * t;
    s[2] = w * w * t;
    s[3] = w * t * t * (py[0] - py[3]);
    s[4] = s[1];
    s[5] = s[2];

    // main loop of the program
    for(int i=0; i<NMC; i++){
        xz    = frand_xz();           //obten #aleatorios x(0),z(1),x'(2),z'(3)
        yd_x  = fy(xz[0], abd);            // yd(x)
        yu_x  = fy(xz[0], abu);            // yu(x)
        Dy    = yu_x - yd_x;
        yd_xp = fy(xz[2], abd);           // yd(x')
        yu_xp = fy(xz[2], abu);
        Dyp   = yu_xp - yd_xp;            // yu(x')
        yi[0] = frand(yd_x, yu_x);        // yd(x)  <  y(x)  < yu(x)
        yi[1] = frand(yd_xp, yu_xp);      // yd(x') <  y(x') < yu(x')
        yi[2] = frand(py[2], py[1]);      // P3y    <  y     < P2y
        yi[3] = frand(py[3], py[0]);      // P4y    <  y     < P1y


        x[0] = xz[0];
        x[1] = yi[0];
        x[2] = xz[1];

        //********* S1 ************OK
        x[3] = 0.5*w;  // x'
        x[4] = yi[2];  // y'
        x[5] = xz[3];  // z'
        abc  = fu(x);
        *a  += *abc     * Dy;
        *b  += *(abc+1) * Dy;
        *c  += *(abc+2) * Dy;

        //********* S2 ************OK
        x[3] = xz[2];  // x'
        x[4] = yu_xp;  // y'
        x[5] = xz[3];  // z'
        abc  = fu(x);
        *(a+1) += *abc     * Dy;
        *(b+1) += *(abc+1) * Dy;
        *(c+1) += *(abc+2) * Dy;

        //********* S3 ************OK
        x[3] = xz[2];
        x[4] = yi[1];
        x[5] = 0.5*t;
        abc  = fu(x);
        *(a+2) += *abc     * Dy*Dyp;
        *(b+2) += *(abc+1) * Dy*Dyp;
        *(c+2) += *(abc+2) * Dy*Dyp;

        //********* S4 ************OK
        x[3] = -0.5*w;
        x[4] = yi[3];
        x[5] = xz[3];
        abc  = fu(x);
        *(a+3) += *abc     * Dy;
        *(b+3) += *(abc+1) * Dy;
        *(c+3) += *(abc+2) * Dy;

        //********* S5 ************OK
        x[3] = xz[2];  // x'
        x[4] = yd_xp;  // y'
        x[5] = xz[3];  // z'
        abc  = fu(x);
        *(a+4) += *abc     * Dy;
        *(b+4) += *(abc+1) * Dy;
        *(c+4) += *(abc+2) * Dy;

        //********* S6 ********************************************
        x[3] = xz[2];
        x[4] = yi[1];
        x[5] = -0.5*t;
        abc  = fu(x);
        *(a+5) += *abc     * Dy*Dyp;
        *(b+5) += *(abc+1) * Dy*Dyp;
        *(c+5) += *(abc+2) * Dy*Dyp;
    }


    for(int i=0; i<6; i++){
        abc_out[i]    = s[i] * a[i] / double(NMC);
        abc_out[i+6]  = s[i] * b[i] / double(NMC);
        abc_out[i+12] = s[i] * c[i] / double(NMC);
    }

    return abc_out;
}

double ** LLGMagnetMagnetization::computeDemag(){
    string key;
    for(int i=0; i<4; i++)
        key += "x" + to_string(px[i]) + "y" + to_string(py[i]);


    if(this->demagBib.find(key) != this->demagBib.end()){
        this->volume = volumeBib[key];
        return this->demagBib[key];
    }


    double *ptr, vol;
    double alfa2, beta2, alfa5, beta5, d[18];
    double ** returnValue;

    returnValue = (double **) malloc(3*sizeof(double *));
    for(int i=0; i<3; i++)
        returnValue[i] = (double*) malloc(3*sizeof(double));

    // Inicia seed de acordo com o clock: gera # pseudoaleatorios cada vez que o programa rodar
    srand(time(NULL));


//  definition of functions yu(x) and yd(x) coefficients: yu =au*x+bu=ab[0]x+ab[1] and yd =ad*x+bd=ab[2]x+ab[3]
//  the vectors abu and abd are global
    w =  px[1] - px[0];
    abu[0] = (py[1] - py[0])/w;                       // au
    abu[1] =  py[0] - abu[0]*px[0];                   // bu
    abd[0] = (py[2] - py[3])/w;                       // ad
    abd[1] =  py[3] - abd[0]*px[3];                   // bd

    alfa2 = -abu[0];
    beta2 =  1;
    alfa5 =  abd[0];
    beta5 = -1;

    ptr = demag(py);

    d[0] = ptr[0]+alfa2*ptr[1]-ptr[3]+alfa5*ptr[4];
    d[1] = beta2*ptr[1]+beta5*ptr[4];
    d[2] = 0;

    d[3] = ptr[6]+alfa2*ptr[7]-ptr[9]+alfa5*ptr[10];
    d[4] = beta2*ptr[7]+beta5*ptr[10];
    d[5] = 0;

    d[6] = 0;
    d[7] = 0;
    d[8] = ptr[14]-ptr[17];

    this->volume = 0.5*(py[0]-py[3]+py[1]-py[2])*w*t;

    for(int i=0; i<3; i++)
        for(int j=0; j<3; j++)
            returnValue[i][j] = d[i*3+j] / (4.0*PI*this->volume);

    demagBib[key] = returnValue;
    volumeBib[key] = volume;
    return returnValue;
}

double LLGMagnetMagnetization::getVolume(){
    // cout << "OK\n";
    // this->volume = 0.5*(py[0]-py[3]+py[1]-py[2])*w*t;
    return this->volume;
}

double * LLGMagnetMagnetization::getPx(){
    return this->px;
}

double * LLGMagnetMagnetization::getPy(){
    return this->py;
}

double LLGMagnetMagnetization::getThickness(){
    return this->t;
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

double * LLGMagnetMagnetization::computeDipolar(double * p2x, double * p2y, double thickness, double verticalDistance, double horizontalDistance){
    string key = "vd" + to_string(verticalDistance) + "hd" + to_string(horizontalDistance);
    for(int i=0; i<4; i++)
        key += "x" + to_string(px[i]) + "y" + to_string(py[i]);
    for(int i=0; i<4; i++)
        key += "x" + to_string(p2x[i]) + "y" + to_string(p2y[i]);
    key += "t1" + to_string(this->t) + "t2" + to_string(thickness);
    if(this->dipBib.find(key) != this->dipBib.end()){
        return this->dipBib[key];
    }

    double p1center[3], p2center[3];//, p2xMod[4], p2yMod[4];
    p1center[0] = 0.0;
    p1center[1] = 0.0;
    p1center[2] = 0.0;
    p2center[0] = horizontalDistance;
    p2center[1] = verticalDistance;
    p2center[2] = 0.0;

    double pc[7] = { 0.0 };

    dipolar3D3(this->px, this->py, &(this->t), p1center, p2x, p2y, &thickness, p2center, pc);
    for(int i=0; i<7; i++)
        pc[i]  /= (4.0*PI*this->volume);

    double * tensor;
    tensor = (double *) malloc(9*sizeof(double));

    tensor[0] = pc[0] + pc[1];
    tensor[1] = pc[4];
    tensor[2] = pc[5];

    tensor[3] = pc[4];
    tensor[4] = pc[0] + pc[2];
    tensor[5] = pc[6];

    tensor[6] = pc[5];
    tensor[7] = pc[6];
    tensor[8] = pc[0] + pc[3];

    this->dipBib[key] = tensor;

    return tensor;
}
