#include "../Others/Includes.h"

#ifndef NEIGHBOR_H
#define NEIGHBOR_H

class Magnet;

class Neighbor{
private:
	Magnet * magnet;
	double * weight;

public:
	Neighbor(Magnet * neighbor, double * weight);
	double * getWeight();
	Magnet * getMagnet();
	void updateWeight(double * weight);
};

#endif