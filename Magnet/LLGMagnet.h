#include "../Others/Includes.h"
#include "../Simulator/FileReader.h"
#include "Magnet.h"
#include "LLGMagnetMagnetization.h"
#include <chrono>
#include <random>

#ifndef LLGMAGNET_H
#define LLGMAGNET_H

#define PI 3.1415926535897
#define mu0 4*PI*pow(10.0, -7.0) //N/A2 ->   m.kg.s-2
#define kb 1.38064852*pow(10.0, -23.0) //J/K  ->   m2.kg.s-2.K-1
#define gammamu0 mu0*1.760859644*pow(10.0, 11.0) //%m/(sA)

class LLGMagnet : protected Magnet{
private:
	string id;
	double magnetization[3];
	double newMagnetization[3];
	vector <Neighbor *> neighbors;
	bool fixedMagnetization;
	LLGMagnetMagnetization * magnetizationCalculator;
	double volume;
	double nd[3][3];
	double xPosition, yPosition;
	bool firstIteration = true;

	static double alpha;
	static double alpha_l;
	static double Ms;
	static double temperature;
	static double timeStep;
	static double v [3];
	static double dt;
	static double dW [3];

	void initializeConstants();
	void crossProduct(double *vect_A, double *vect_B, double *cross_P);
	void f_term(double * currMag, double * currSignal, double* hd, double* hc, double * result);
	vector<string> splitString(string str, char separator);

public:
	LLGMagnet(string id, FileReader * fReader);//double alpha, double Ms, double temperature, double timeStep);
	void calculateMagnetization(ClockPhase * phase);
	void buildMagnet(vector <string> descParts);
	double * getMagnetization();
	void updateMagnetization();
	void addNeighbor(Magnet * neighbor, double * ratio);
	void dumpValues(ofstream * outFile);
	string getId();
	void setMagnetization(double * magnetization);
	double * getPx();
	double * getPy();
	double getThickness();
	double getXPosition();
	double getYPosition();
	bool isNeighbor(LLGMagnet * magnet, double ratio);
};

#endif