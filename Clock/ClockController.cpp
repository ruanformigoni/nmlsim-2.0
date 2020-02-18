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
		vector<Magnet *> magnets = zones[i]->getAllMagnets();
		//Update their magnets magnetization
		for(int j=0; j<magnets.size(); j++){
			magnets[j]->calculateMagnetization(zones[i]);
		}
		//Update the values
		for(int j=0; j<magnets.size(); j++){
			magnets[j]->updateMagnetization();
		}
		// this->zones[i]->updateMagnets();
		//Update the time in the phase
		this->zones[i]->incrementStepsInPhase();
		//Check if the phase has ended
		if(this->zones[i]->isPhaseEnded(this->deltaTime)){
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
}

void ClockController::addMagnetToZone(Magnet * magnet, int zoneIndex){
	if(zoneIndex >= 0 && zoneIndex < this->zones.size())
		this->zones[zoneIndex]->addMagnet(magnet);
}

ClockZone * ClockController::getClockZone(int zoneId){
	return this->zones[zoneId];
}

void ClockController::dumpMagnetsValues(ofstream * outFile){
	for(int i=0; i<zones.size(); i++){
		vector <Magnet *> magnets = zones[i]->getAllMagnets();
		for(int j=0; j<magnets.size(); j++){
			magnets[j]->dumpValues(outFile);
		}
	}
}

void ClockController::makeHeader(ofstream * outFile){
	for(int i=0; i<zones.size(); i++){	
		vector <Magnet *> magnets = zones[i]->getAllMagnets();
		for(int j=0; j<magnets.size(); j++){
			magnets[j]->makeHeader(outFile);
		}
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