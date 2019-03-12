#include "Neighbor.h"

Neighbor::Neighbor(Magnet * neighbor, double * weight){
	this->magnet = neighbor;
	this->weight = weight;
}

double * Neighbor::getWeight(){
	return this->weight;
}

Magnet * Neighbor::getMagnet(){
	return this->magnet;
}
