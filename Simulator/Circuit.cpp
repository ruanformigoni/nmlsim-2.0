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

Magnet* Circuit::getMagnet(string inOrOut, string id){
	if(inOrOut == "input"){
		//Check for an input
		for(int i=0; i<this->inputMagnets.size(); i++)
			if(this->inputMagnets[i]->getId() == id)
				return this->inputMagnets[i];
	} else if(inOrOut == "output"){
		//Check for an output
		for(int i=0; i<this->outputMagnets.size(); i++)
			if(this->outputMagnets[i]->getId() == id)
				return this->outputMagnets[i];
	} else{
		//Return NULL in case it is not an input or output
		return NULL;
	}
	//Return NULL if it doesn't find anything
	return NULL;
}

void Circuit::dumpMagnetsValues(ofstream * outFile){
	this->clockCtrl->dumpMagnetsValues(outFile);
}

void Circuit::makeHeader(ofstream * outFile){
	this->clockCtrl->makeHeader(outFile);
}

void Circuit::dumpInOutValues(ofstream * outFile){
	*(outFile) << "input" << endl;
	for(int i=0; i<this->inputMagnets.size(); i++)
		this->inputMagnets[i]->dumpValues(outFile);

	*(outFile) << "\noutput" << endl;
	for(int i=0; i<this->outputMagnets.size(); i++)
		this->outputMagnets[i]->dumpValues(outFile);
}

void Circuit::setInputs(int mask, simulationType type){
	//For each input magnet
	for(int i=0; i<inputMagnets.size(); i++){
		//Find the corresponding bit in the mask
		int bitMask = 1 << i;
		int maskedBit = mask & bitMask;
		int bit = maskedBit >> i;

		//Each engine has a different type of magnetization
		switch(type){
			case THIAGO:{
				//If the bit is 0, points down. If not, points up
				double aux;
				if(bit == 0){
					aux = -1.0;
				} else {
					aux = 1.0;
				}
				inputMagnets[i]->setMagnetization(&aux);
			}
			break;
			case LLG:{
				//If the bit is 0, points down. If not, points up
				double aux[3];
				if(bit == 0){
					aux[0] = 0.1411;
					aux[1] = -0.99;
					aux[2] = 0.0;
				} else{
					aux[0] = 0.1411;
					aux[1] = 0.99;
					aux[2] = 0.0;
				}
				inputMagnets[i]->setMagnetization(aux);
			}
		}
	}
}

int Circuit::getInputsSize(){
	return this->inputMagnets.size();
}

vector <Magnet *> Circuit::getAllMagnets(){
	vector <Magnet *> magnets;

	//Magnets from zones
	magnets = clockCtrl->getMagnetsFromAllZones();

	//Input magnets
	for(int i=0; i<inputMagnets.size(); i++){
		if(find(magnets.begin(), magnets.end(), inputMagnets[i]) == magnets.end()){
			magnets.push_back(inputMagnets[i]);
		}
	}

	//Output magnets
	for(int i=0; i<outputMagnets.size(); i++){
		if(find(magnets.begin(), magnets.end(), outputMagnets[i]) == magnets.end()){
			magnets.push_back(outputMagnets[i]);
		}
	}
	return magnets;
}

Magnet * Circuit::getMagnet(string id){
	//Magnets from zones
	vector <Magnet *> magnets;
	magnets = clockCtrl->getMagnetsFromAllZones();
	for(Magnet * mag : magnets){
		if(mag->getId() == id)
			return mag;
	}

	//Input magnets
	for(Magnet * mag : inputMagnets){
		if(mag->getId() == id)
			return mag;
	}
	
	//Output magnets
	for(Magnet * mag : outputMagnets){
		if(mag->getId() == id)
			return mag;
	}

	return NULL;
}

void Circuit::restartAllMagnets(){
	vector <Magnet *> magnets = getAllMagnets();
	for(int i=0; i<magnets.size(); i++)
		magnets[i]->resetMagnetization();
}

void Circuit::resetZonesPhases(){
	clockCtrl->resetZonesPhases();
}