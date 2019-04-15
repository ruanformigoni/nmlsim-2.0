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
	for(int i=0; i<this->magnets.size(); i++){
		this->magnets[i]->calculateMagnetization(this->myPhase);
	}
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
//cout << "From " << myPhase->getPhaseName() << " to " << newPhase->getPhaseName() << endl;
	this->myPhase = newPhase;
	resetTimeInPhase();
}

void ClockZone::dumpMagnetsValues(ofstream * outFile){
	for(int i=0; i<magnets.size(); i++){
		magnets[i]->dumpValues(outFile);
	}
	if(magnets.size() > 0){
		this->myPhase->dumpValues(outFile);
//		double * aux = this->myPhase->getSignal();
//		*(outFile) << aux[0] << "," << aux[1] << "," << aux[2] << ",";
	}
}

void ClockZone::dumpPhaseValues(ofstream * outFile){
	this->myPhase->dumpValues(outFile);
}

Magnet * ClockZone::getMagnet(string magnetId){
	for(int i=0; i< magnets.size(); i++)
		if(magnets[i]->getId() == magnetId)
			return magnets[i];
	return NULL;
}

vector <Magnet *> ClockZone::getAllMagnets(){
	return this->magnets;
}
