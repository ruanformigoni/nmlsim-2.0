#include "Neighbor.h"

//Constructor
Neighbor::Neighbor(Magnet * neighbor, double * weight){
	this->magnet = neighbor;
	this->weight = weight;
}

//Returns the weight
double * Neighbor::getWeight(){
	return this->weight;
}

//Returns the magnet
Magnet * Neighbor::getMagnet(){
	return this->magnet;
}

//Update the weight. Used in Thiago's magnet
void Neighbor::updateWeight(double * weight){
	this->weight = weight;
}