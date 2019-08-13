#include "../Others/Includes.h"
#include "../Clock/ClockPhase.h"
#include "Neighbor.h"

#ifndef MAGNET_H
#define MAGNET_H

class Magnet{
protected:
	string id;
	double * magnetization;
	vector <Neighbor *> neighbors;

public:
	virtual double * getMagnetization() = 0;
	virtual void calculateMagnetization(ClockPhase * phase) = 0;
	virtual void updateMagnetization() = 0;
	virtual void addNeighbor(Magnet * neighbor, double * weight) = 0;
	virtual void dumpValues(ofstream * outFile) = 0;
	virtual void makeHeader(ofstream * outFile) = 0;
	virtual string getId() = 0;
	virtual void setMagnetization(double * magnetization) = 0;
	virtual void resetMagnetization() = 0;
	virtual double * getTensorsAverage(double * npx, double * npy, double nt, double vDist, double hDist) = 0;
	virtual vector <Neighbor *> getNeighbors() = 0;
	virtual double ** getDemagTensor() = 0;
};

#endif