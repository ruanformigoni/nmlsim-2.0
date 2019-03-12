#include "Circuit.h"

Circuit::Circuit(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime){
	this->clockCtrl = new ClockController(zones, phases, deltaTime);
}

Circuit::Circuit(vector <Magnet*> input, vector <Magnet*> output, vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime){
	this->inputMagnets = input;
	this->outputMagnets = output;
	this->clockCtrl = new ClockController(zones, phases, deltaTime);
}

void Circuit::addMagnetToZone(Magnet * magnet, int zoneID){
	this->clockCtrl->addMagnetToZone(magnet, zoneID);
}

void Circuit::addInputMagnet(Magnet * magnet){
	this->inputMagnets.push_back(magnet);
}

void Circuit::addOutputMagnet(Magnet * magnet){
	this->outputMagnets.push_back(magnet);
}

void Circuit::nextTimeStep(){
	this->clockCtrl->nextTimeStep();
}

Magnet * Circuit::getMagnet(string inOrOut, string id){
	if(inOrOut == "input"){
		for(int i=0; i<this->inputMagnets.size(); i++)
			if(this->inputMagnets[i]->getId() == id)
				return this->inputMagnets[i];
	} else if(inOrOut == "output"){
		for(int i=0; i<this->outputMagnets.size(); i++)
			if(this->outputMagnets[i]->getId() == id)
				return this->outputMagnets[i];
	} else{
		return NULL;
	}
}

Magnet * Circuit::getMagnet(int zoneId, string id){
	return this->clockCtrl->getClockZone(zoneId)->getMagnet(id);
}

void Circuit::dumpZonesValues(ofstream * outFile){
	this->clockCtrl->dumpZonesValues(outFile);
}

void Circuit::dumpMagnetsValues(ofstream * outFile){
	this->clockCtrl->dumpMagnetsValues(outFile);
}

void Circuit::dumpInOutValues(ofstream * outFile){
	*(outFile) << "input" << endl;
	for(int i=0; i<this->inputMagnets.size(); i++)
		this->inputMagnets[i]->dumpValues(outFile);
	*(outFile) << "\noutput" << endl;
	for(int i=0; i<this->outputMagnets.size(); i++)
		this->outputMagnets[i]->dumpValues(outFile);
}

void Circuit::setInputs(int mask){
	for(int i=0; i<inputMagnets.size(); i++){
		int bitMask = 1 << i;
		int maskedBit = mask & bitMask;
		int bit = maskedBit >> i;
		double aux;
		if(bit == 0){
			aux = -1.0;
			inputMagnets[i]->setMagnetization(&aux);
		} else if (bit == 1){
			aux = 1.0;
			inputMagnets[i]->setMagnetization(&aux);
		}
	}
}

int Circuit::getInputsSize(){
	return this->inputMagnets.size();
}

vector <Magnet *> Circuit::getAllMagnets(){
	vector <Magnet *> magnets;
	magnets = clockCtrl->getMagnetsFromAllZones();
	for(int i=0; i<inputMagnets.size(); i++){
		if(find(magnets.begin(), magnets.end(), inputMagnets[i]) == magnets.end()){
			magnets.push_back(inputMagnets[i]);
		}
	}

	for(int i=0; i<outputMagnets.size(); i++){
		if(find(magnets.begin(), magnets.end(), outputMagnets[i]) == magnets.end()){
			magnets.push_back(outputMagnets[i]);
		}
	}
	return magnets;
}
