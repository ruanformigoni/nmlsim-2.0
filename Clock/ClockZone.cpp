#include "ClockZone.h"

ClockZone::ClockZone(ClockPhase * phase, vector <string> phases){
	this->myPhase = phase;
	this->myPhases = phases;
	this->timeInPhase = 0.0;
}

string ClockZone::getZonePhase(){
	return this->myPhase->getPhaseName();
}

double * ClockZone::getZoneSignal(){
	return this->myPhase->getSignal();
}

void ClockZone::addMagnet(Magnet * magnet){
	this->magnets.push_back(magnet);
}

void ClockZone::updateMagnets(){
	//Compute future magnetizations
	for(int i=0; i<this->magnets.size(); i++){
		this->magnets[i]->calculateMagnetization(this->myPhase);
	}
	//Update the values
	for(int i=0; i<this->magnets.size(); i++){
		this->magnets[i]->updateMagnetization();
	}
}

double ClockZone::getTimeInPhase(){
	return this->timeInPhase;
}

void ClockZone::updateTimeInPhase(double variation){
	this->timeInPhase += variation;
}

void ClockZone::resetTimeInPhase(){
	this->timeInPhase = 0.0;
}

bool ClockZone::isPhaseEnded(){
	return (this->timeInPhase >= myPhase->getPhaseDuration());
}

vector<string> ClockZone::getPhases(){
	return this->myPhases;
}

void ClockZone::updatePhase(ClockPhase * newPhase){
	this->myPhase = newPhase;
	resetTimeInPhase();
}

void ClockZone::dumpMagnetsValues(ofstream * outFile){
	for(int i=0; i<magnets.size(); i++){
		magnets[i]->dumpValues(outFile);
	}
}

void ClockZone::makeHeader(ofstream * outFile){
	for(int i=0; i<magnets.size(); i++){
		magnets[i]->makeHeader(outFile);
	}
}

void ClockZone::dumpPhaseValues(ofstream * outFile){
	this->myPhase->dumpValues(outFile);
}

//Returns the magnet of NULL in case it doesn't exists
Magnet * ClockZone::getMagnet(string magnetId){
	for(int i=0; i< magnets.size(); i++)
		if(magnets[i]->getId() == magnetId)
			return magnets[i];
	return NULL;
}

vector <Magnet *> ClockZone::getAllMagnets(){
	return this->magnets;
}