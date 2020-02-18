#include "../Others/Includes.h"
#include <cmath>
#include <map>

#ifndef LLGTENSORS_H
#define LLGTENSORS_H

#define PI 3.1415926535897

//This class is used to compute the demag and dipolar tensors
class LLGTensors{
private:
	const int NMC = 1000000;	//Number of samplings for the Monte Carlo method
	double w, t;	//Width and thickness of the magnet
	double abu[2], abd[2]; //yu(x)= abu[0]x +abu[1] and yd(x)= abd[0]x +abd[1]
	double volume;	//Volume of the magnet
	double * px, * py;	//Cartesian references for the four points of the magnet

	//Methods used in the Monte Carlo
	double  frand(double, double);
	double * frand_xz();
	double * fu(double []);
	double  fy(double, const double []);
	double * demag(double *);

public:
	//Constructor with the points
	LLGTensors(double * px, double * py, double thickness);
	//Constructor without the points
	LLGTensors(double widht, double height, double thickness, double topCut, double bottomCut);
	//Method to compute the demag tensor
	double ** computeDemag();
	//Method to compute the dipolar tensor
	double * computeDipolar(double * px, double * py, double thickness, double verticalDistance, double horizontalDistance);
	//Returns the x points
	double * getPx();
	//Returns the y points
	double * getPy();
	//Returns the thickness
	double getThickness();
	//Returns the volume
	double getVolume();
	//Compute the best demag tensor
	double ** computeBestTensor(double **tensors[10], int repetitions, int size);
};

#endif