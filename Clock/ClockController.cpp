#include "ClockController.h"

ClockController::ClockController(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime){
	//Add the zones
	for(int i=0; i<zones.size(); i++)
		this->zones.push_back(zones[i]);
	//Add the phases
	for(int i=0; i<phases.size(); i++)
		this->phases.push_back(phases[i]);
	//Set the time step
	this->deltaTime = deltaTime;
}

void ClockController::nextTimeStep(){
	//For every clock zone...
	for(int i=0; i<this->zones.size(); i++){
		//Update their magnets magnetization
		this->zones[i]->updateMagnets();
		//Update the time in the phase
		this->zones[i]->updateTimeInPhase(this->deltaTime);
		//Check if the phase has ended
		if(this->zones[i]->isPhaseEnded()){
			string nextPhase;
			vector <string> phasesOrder = this->zones[i]->getPhases();
			//Finds the index of the current phase in the order
			for(int j=0; j<phasesOrder.size(); j++){
				if(this->zones[i]->getZonePhase() == phasesOrder[j]){
					if(j == phasesOrder.size()-1){
						nextPhase = phasesOrder[0];
					} else{
						nextPhase = phasesOrder[j+1];
					}
				}
			}
			//Retrives the next phase
			ClockPhase * nextPhaseAux;
			for(int j=0; j<this->phases.size(); j++)
				if(this->phases[j]->getPhaseName() == nextPhase)
					nextPhaseAux = phases[j];
			//Update the phase
			this->zones[i]->updatePhase(nextPhaseAux);
		}
	}
	//Update all phases time
	for(int i=0; i<this->phases.size(); i++){
		phases[i]->nextTimeStep(this->deltaTime);
	}
}

void ClockController::addMagnetToZone(Magnet * magnet, int zoneIndex){
	if(zoneIndex >= 0 && zoneIndex < this->zones.size())
		this->zones[zoneIndex]->addMagnet(magnet);
}

void ClockController::dumpZonesValues(ofstream * outFile){
	for(int i=0; i<zones.size(); i++){
		zones[i]->dumpPhaseValues(outFile);
	}
}

ClockZone * ClockController::getClockZone(int zoneId){
	return this->zones[zoneId];
}

void ClockController::dumpMagnetsValues(ofstream * outFile){
	for(int i=0; i<zones.size(); i++){
		zones[i]->dumpMagnetsValues(outFile);
	}
}

void ClockController::makeHeader(ofstream * outFile){
	for(int i=0; i<zones.size(); i++){
		zones[i]->makeHeader(outFile);
	}	
}

vector <Magnet *> ClockController::getMagnetsFromAllZones(){
	vector <Magnet *> magnets, aux;
	for(int i=0; i<this->zones.size(); i++){
		aux = zones[i]->getAllMagnets();
		magnets.insert(magnets.end(),  aux.begin(), aux.end());
	}
	return magnets;
}

void ClockController::restartAllPhases(){
	for(int i=0; i<phases.size(); i++)
		phases[i]->restartPhase();
}

void ClockController::resetZonesPhases(){
	//For each zone...
	for(int i=0; i<zones.size(); i++){
		//Get the initial phase name
		string aux = zones[i]->getPhases()[0];
		//Retrieve the initial phase
		ClockPhase * nextPhaseAux;
		for(int j=0; j<this->phases.size(); j++)
			if(this->phases[j]->getPhaseName() == aux)
				nextPhaseAux = phases[j];
		//Update the phase
		this->zones[i]->updatePhase(nextPhaseAux);
	}
}