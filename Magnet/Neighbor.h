#include "../Others/Includes.h"

#ifndef NEIGHBOR_H
#define NEIGHBOR_H

//Forward declaration of the magnet class
class Magnet;

//Class that relates two magnets as neighbors
//Obejcts of this class should be inside a Magnet class!
class Neighbor{
private:
	Magnet * magnet;	//The other magnet
	double * weight;	//The weight of their iteraction, which can be the demag tensor

public:
	//Constructor
	Neighbor(Magnet * neighbor, double * weight);
	//Returns the weight
	double * getWeight();
	//Returns the magnet
	Magnet * getMagnet();
	//Update the weight. Used in Thiago's magnet
	void updateWeight(double * weight);
};

#endif