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
#define hbar 2.05457*pow(10,(-34)) //J.s/rad  -> h/2pi
#define q 1.60217662*pow(10,(-19)) // carga do eletron C

class LLGMagnet : protected Magnet{
private:
	string id;
	double magnetization[3];
	double initialMagnetization[3];
	double newMagnetization[3];
	vector <Neighbor *> neighbors;
	bool fixedMagnetization;
	LLGMagnetMagnetization * magnetizationCalculator;
	double volume;
	double nd[3][3];
	double dW [3];
	double xPosition, yPosition;
	double theta_she;

	static double alpha;
	static double alpha_l;
	static double Ms;
	static double temperature;
	static double timeStep;
	static double bulk_sha;
	static double v [3];
	static double dt;
	static double l_shm;
	static double th_shm;
	static bool initialized;
	static bool rk4Method;

	void initializeConstants();
	void crossProduct(double *vect_A, double *vect_B, double *cross_P);
	void f_term(double * currMag, double * currSignal, double* hd, double* hc, double* i_s, double * result);
	vector<string> splitString(string str, char separator);
	void a_term(double* a, double* h_eff, double* i_s, double* m);
	void b_term(double* b, double* m);

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
	void resetMagnetization();
	double * getPx();
	double * getPy();
	double getThickness();
	double getXPosition();
	double getYPosition();
	bool isNeighbor(LLGMagnet * magnet, double ratio);
	void makeHeader(ofstream * out);
};

#endif