#include "../Others/Includes.h"
#include "../Simulator/FileReader.h"
#include "Magnet.h"
#include "LLGMagnetMagnetization.h"
#include <chrono>
#include <random>

#ifndef THIAGOMAGNET_H
#define THIAGOMAGNET_H

//Used to simulate thermal noise
#define THERMAL_ENERGY 0.00477678

//The behaviour engine magnet
class ThiagoMagnet : public Magnet{
private:
	string id;	//Magnet name from xml file
	magnetType myType;	//Input, output or regular
	double magnetization;	//Y magnetization from -1 to 1
	double initialMagnetization;	//Value for the initial state
	double tempMagnetization;	//Auxiliar variable
	bool fixedMagnetization;	//No field effect from xml file
	vector <Neighbor *> neighbors;	//List of neighbors magnets
	LLGMagnetMagnetization * magnetizationCalculator;	//Class to compute the tensors
	double xPosition;	//Position in plane
	double yPosition;	//Position in plane

	static double neighborhoodRatio;	//Neighborhood radius

	vector<string> splitString(string str, char separator);	//method to split string into parts

public:
	//This method builds the magnet from the file reader info
    ThiagoMagnet(string id, FileReader * fReader);
    //Returns the current magnetization
	double * getMagnetization();
	//Compute the future magnetization depending on the clock phase
	void calculateMagnetization(ClockPhase * phase);
	//Update the current magnetization to the future magnetization
	void updateMagnetization();
	//Print values into file
	void dumpValues(ofstream * outFile);
	//Print header into file
	void makeHeader(ofstream * outFile);
	//Returns the id
	string getId();
	//Set the current magnetization to a determined value
	void setMagnetization(double * magnetization);
	//Returns if another magnet is a neighboor
	bool isNeighbor(ThiagoMagnet * magnet);
	//Adds another magnet as a neighbor dependind on a neighborhood radius
	void addNeighbor(Magnet * neighbor, double * neighborhoodRatio);
	//Returns the vector of x coordinates of the geometry
	double * getPx();
	//Returns the vector of y coordinates of the geometry
	double * getPy();
	//Returns the thickness
	double getThickness();
	//Returns the position
	double getXPosition();
	//Returns the position
	double getYPosition();
	//Normalize the tensors so that the most impactfull one has heigh equal to 1
	void normalizeWeights();
	//Set the current magnetization to the initial magnetization
	void resetMagnetization();
	double * getTensorsAverage(double * npx, double * npy, double nt, double vDist, double hDist);
	vector <Neighbor *> getNeighbors();
	double ** getDemagTensor(){};
};

#endif