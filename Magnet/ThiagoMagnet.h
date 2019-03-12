#include "../Others/Includes.h"
#include "../Simulator/FileReader.h"
#include "Magnet.h"
#include "LLGMagnetMagnetization.h"
#include <chrono>
#include <random>

#ifndef THIAGOMAGNET_H
#define THIAGOMAGNET_H

#define THERMAL_ENERGY 0.00477678

class ThiagoMagnet : protected Magnet{
private:
	string id;
	magnetType myType;
	double magnetization;
	double tempMagnetization;
	bool fixedMagnetization;
	vector <Neighbor *> neighbors;
	LLGMagnetMagnetization * magnetizationCalculator;
	double xPosition;
	double yPosition;

	static double neighborhoodRatio;

	vector<string> splitString(string str, char separator);

public:
    ThiagoMagnet(string id, FileReader * fReader);
	void buildMagnet(vector <string> descParts);
	double * getMagnetization();
	void calculateMagnetization(ClockPhase * phase);
	void updateMagnetization();
	void dumpValues(ofstream * outFile);
	string getId();
	void setMagnetization(double * magnetization);
	bool isNeighbor(ThiagoMagnet * magnet);
	void addNeighbor(Magnet * neighbor, double * neighborhoodRatio);
	double * getPx();
	double * getPy();
	double getThickness();
	double getXPosition();
	double getYPosition();
};

#endif