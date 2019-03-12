#include "../Others/Includes.h"
#include <cmath>
#include <map>

#ifndef LLGMAGNETMAGNETIZATION_H
#define LLGMAGNETMAGNETIZATION_H

#define PI 3.1415926535897

class LLGMagnetMagnetization{
private:
	const int NMC = 1000000;
	double w, t;
	double abu[2], abd[2]; //yu(x)= abu[0]x +abu[1] and yd(x)= abd[0]x +abd[1]
	double volume;
	double * px, * py;

	static map<string, double *> dipBib;
	static map<string, double **> demagBib;
	static map<string, double> volumeBib;

	double  frand(double, double);
	double * frand_xz();
	double * fu(double []);
	double  fy(double, const double []);
	double * demag(double *);

public:
	LLGMagnetMagnetization(double * px, double * py, double thickness);
	double ** computeDemag();
	double * computeDipolar(double * px, double * py, double thickness, double verticalDistance, double horizontalDistance);
	double * getPx();
	double * getPy();
	double getThickness();
	double getVolume();
};

#endif