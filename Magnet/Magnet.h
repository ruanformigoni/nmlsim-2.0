#include "../Others/Includes.h"
#include "../Clock/ClockPhase.h"
#include "Neighbor.h"

#ifndef MAGNET_H
#define MAGNET_H

//Interface for the Magnet
class Magnet{
protected:
	string id;	//Some sort of id code
	double * magnetization;	//The magnetization can have as many components as needed
	vector <Neighbor *> neighbors;	//A list of neighbors to build the graph

public:
	//Returns the current magnetization value
	virtual double * getMagnetization() = 0;
	//Compute the magnetization for the next step of time
	virtual void calculateMagnetization(ClockPhase * phase) = 0;
	//Update the magnetization
	virtual void updateMagnetization() = 0;
	//Add a magnet as a neighbor
	virtual void addNeighbor(Magnet * neighbor, double * weight) = 0;
	//Print the desired data into a file
	virtual void dumpValues(ofstream * outFile) = 0;
	//Make a header for the output file
	virtual void makeHeader(ofstream * outFile) = 0;
	//Return the id
	virtual string getId() = 0;
	//Set the magnetization value
	virtual void setMagnetization(double * magnetization) = 0;
	//Set the magnetization value to the original default
	virtual void resetMagnetization() = 0;
	//Return the list of neighbors
	virtual vector <Neighbor *> getNeighbors() = 0;
};

#endif