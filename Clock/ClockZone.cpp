#include "ClockZone.h"

ClockZone::ClockZone(ClockPhase * phase, vector <string> phases){
	this->myPhase = phase;
	this->myPhases = phases;
	this->stepsInPhase = 0.0;
}

string ClockZone::getZonePhase(){
	return this->myPhase->getPhaseName();
}

double * ClockZone::getSignal(){
	//It needs the number of steps of time in the phase, not the real time
	return this->myPhase->getSignal(this->stepsInPhase);
}

double * ClockZone::getZoneSignalVariation(){
	return this->myPhase->getVariation();
}

void ClockZone::addMagnet(Magnet * magnet){
	this->magnets.push_back(magnet);
}

int ClockZone::getStepsInPhase(){
	return this->stepsInPhase;
}

void ClockZone::incrementStepsInPhase(){
	this->stepsInPhase++;
}

void ClockZone::resetStepsInPhase(){
	this->stepsInPhase = 0;
}

bool ClockZone::isPhaseEnded(double timeStep){
	return (timeStep*this->stepsInPhase >= myPhase->getPhaseDuration());
}

vector<string> ClockZone::getPhases(){
	return this->myPhases;
}

void ClockZone::updatePhase(ClockPhase * newPhase){
	this->myPhase = newPhase;
	resetStepsInPhase();
}

vector <Magnet *> ClockZone::getAllMagnets(){
	return this->magnets;
}