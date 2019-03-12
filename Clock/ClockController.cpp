#include "ClockController.h"
ClockController::ClockController(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime){
	for(int i=0; i<zones.size(); i++)
		this->zones.push_back(zones[i]);
	for(int i=0; i<phases.size(); i++)
		this->phases.push_back(phases[i]);
	this->deltaTime = deltaTime;
}

void ClockController::nextTimeStep(){
	for(int i=0; i<this->zones.size(); i++){
		this->zones[i]->updateTimeInPhase(this->deltaTime);
		if(this->zones[i]->isPhaseEnded()){
			string nextPhase;
			vector <string> phasesOrder = this->zones[i]->getPhases();
			for(int j=0; j<phasesOrder.size(); j++){
				if(this->zones[i]->getZonePhase() == phasesOrder[j]){
					if(j == phasesOrder.size()-1){
						nextPhase = phasesOrder[0];
					} else{
						nextPhase = phasesOrder[j+1];
					}
				}
			}
			ClockPhase * nextPhaseAux;
			for(int j=0; j<this->phases.size(); j++)
				if(this->phases[j]->getPhaseName() == nextPhase)
					nextPhaseAux = phases[j];
			this->zones[i]->updatePhase(nextPhaseAux);
		}
		this->zones[i]->updateMagnets();
	}
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
//		cout << "Zone " << i << endl;
		zones[i]->dumpPhaseValues(outFile);
	}
}

ClockZone * ClockController::getClockZone(int zoneId){
	return this->zones[zoneId];
}

void ClockController::dumpMagnetsValues(ofstream * outFile){
	for(int i=0; i<zones.size(); i++){
		// cout << "Zone " << i << endl;
		zones[i]->dumpMagnetsValues(outFile);
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
