#include "Simulation.h"

Simulation::Simulation(string filePath, string outFilePath){
	this->fReader = new FileReader(filePath);
	this->currentTime = 0.0;
	this->deltaTime = stod(fReader->getProperty(CIRCUIT, "timeStep"));
	this->simulationDuration = stod(fReader->getProperty(CIRCUIT, "simTime"));
	this->mySimType = fReader->getEngine();
	this->mySimMode = fReader->getSimMode();
	this->outFile.open(outFilePath);
	buildClkCtrl();
	buildCircuit();
}

void Simulation::verboseSimulation(double reportDeltaTime){
	double auxTimer = 0.0;
	outFile << currentTime << ",";
	this->circuit->dumpMagnetsValues(&outFile);
	outFile << endl;
	while(this->currentTime < this->simulationDuration){
		auxTimer += this->deltaTime;
		this->currentTime += this->deltaTime;
		this->circuit->nextTimeStep();
		if(auxTimer >= reportDeltaTime){
			outFile << currentTime << ",";
			this->circuit->dumpMagnetsValues(&outFile);
			outFile << endl;
			auxTimer = 0.0;
		}
	}
}

void Simulation::exaustiveSimulation(){
/*	int inputSize = circuit->getInputsSize();
	int limit = (int) pow(2.0, (double) inputSize);
	for(int i=0; i<limit; i++){
		circuit->setInputs(i);
		this->currentTime = 0.0;
		while(this->currentTime < this->simulationDuration){
			this->circuit->nextTimeStep();
			this->currentTime += this->deltaTime;
		}
		cout << "---------------------------------------------\n";
		this->circuit->dumpInOutValues();
	}*/
}

void Simulation::directSimulation(){
	while(this->currentTime < this->simulationDuration){
		this->circuit->nextTimeStep();
		this->currentTime += this->deltaTime;
	}
	this->circuit->dumpInOutValues(&outFile);
	outFile << endl;
}

void Simulation::simulate(){
	switch(this->mySimMode){
		case DIRECT:{
			directSimulation();
		}
		break;
		case EXAUSTIVE:{
			exaustiveSimulation();
		}
		break;
		case VERBOSE:{
			verboseSimulation(stod(fReader->getProperty(CIRCUIT, "reportStep")));
		}
		break;
	}
	this->outFile.close();
}

void Simulation::buildClkCtrl(){
	switch(this->mySimType){
		case THIAGO:{
			//Variables for creating zones and phases
			vector<ClockPhase *> phases;
			vector<ClockZone *> zones;

			vector <string> aux;
			vector <string> parts;
			string value;

			//Creating the phases
			aux = fReader->getItems(PHASE);
			for(int i=0; i<aux.size(); i++){
				double initial[3], end[3], variation[3], duration;
				value = stod(fReader->getItemProperty(PHASE, aux[i], "initialSignal"));
				initial[0] = initial[2] = 0;
				initial[1] = stod(value);
				value = stod(fReader->getItemProperty(PHASE, aux[i], "endSignal"));
				end[0] = end[2] = 0;
				end[1] = stod(value);
				duration = stod(fReader->getItemProperty(PHASE, aux[i], "duration"));
				for(int j=0; j<3; j++){
					variation[j] = (end[j] - initial[j])/(duration/deltaTime);
				}
				ClockPhase * phaseAux = new ClockPhase(aux[i], duration, end, variation);
				phaseAux->setInitialSignal(initial);
				phases.push_back(phaseAux);
			}

			//Creating the zones
			aux = fReader->getItems(ZONE);
			for(int i=0; i<aux.size(); i++){
				parts = fReader->getAllItemProperties(ZONE, aux[i]);
				ClockPhase * phaseAux;
				for(int j=0; j<phases.size(); j++){
					if(phases[j]->getPhaseName() == parts[0]){
						phaseAux = phases[j];
					}
				}
				zones.push_back(new ClockZone(phaseAux, parts));
			}

			//Creating the circuit
			this->circuit = new Circuit(zones, phases, this->deltaTime);
		}
		break;
		case LLG:{
			//Variables for creating zones and phases
			vector<ClockPhase *> phases;
			vector<ClockZone *> zones;

			vector <string> aux;
			vector <string> parts;

			//Creating the phases
			aux = fReader->getItems(PHASE);
			for(int i=0; i<aux.size(); i++){
				double initial[3], end[3], variation[3], duration;
				parts = splitString(fReader->getItemProperty(PHASE, aux[i], "initialSignal"), ',');
				for(int j=0; j<3; j++){
					initial[j] = stod(parts[j]);
				}
				parts = splitString(fReader->getItemProperty(PHASE, aux[i], "endSignal"), ',');
				for(int j=0; j<3; j++){
					end[j] = stod(parts[j]);
				}
				duration = stod(fReader->getItemProperty(PHASE, aux[i], "duration"));
				for(int j=0; j<3; j++){
					variation[j] = (end[j] - initial[j])/(duration/deltaTime);
//cout << end[j] << " - " << initial[j] << " / " << (duration/deltaTime) << " = " << variation[j] << endl;
				}
				ClockPhase * phaseAux = new ClockPhase(aux[i], duration, end, variation);
				phaseAux->setInitialSignal(initial);
				phases.push_back(phaseAux);
			}

			//Creating the zones
			aux = fReader->getItems(ZONE);
			for(int i=0; i<aux.size(); i++){
				parts = fReader->getAllItemProperties(ZONE, aux[i]);
				ClockPhase * phaseAux;
				for(int j=0; j<phases.size(); j++){
					if(phases[j]->getPhaseName() == parts[0]){
						phaseAux = phases[j];
					}
				}
				zones.push_back(new ClockZone(phaseAux, parts));
			}

			//Creating the circuit
			this->circuit = new Circuit(zones, phases, this->deltaTime);
		}
		break;
	}
}

vector<string> Simulation::splitString(string str, char separator){
	vector<string> parts;
	int startIndex = 0;
	for(int i=0; i<str.size(); i++){
		if(str[i] == separator || i == str.size()-1){
			if(i == str.size()-1)
				i++;
			parts.push_back(str.substr(startIndex, i-startIndex));
			startIndex = i+1;
		}
	}
	return parts;
}

void Simulation::buildCircuit(){
	buildMagnets();
	buildNeighbors();
}

void Simulation::buildMagnets(){
	switch(this->mySimType){
		case THIAGO:{
			vector<string> magnetsIds = fReader->getItems(DESIGN);
			for(int i=0; i<magnetsIds.size(); i++){
				Magnet * magnet = (Magnet *) new ThiagoMagnet(magnetsIds[i], fReader);
				string magType = fReader->getItemProperty(DESIGN, magnetsIds[i], "myType");
				if(magType == "input"){
					this->circuit->addInputMagnet(magnet);
				} else if(magType == "output"){
					this->circuit->addOutputMagnet(magnet);
				}
				string clkZoneStr = fReader->getItemProperty(DESIGN, magnetsIds[i], "clockZone");
				if(clkZoneStr != "none"){
					this->circuit->addMagnetToZone(magnet, stoi(clkZoneStr));
				}
			}
		}
		break;
		case LLG:{
			vector<string> magnetsIds = fReader->getItems(DESIGN);
			for(int i=0; i<magnetsIds.size(); i++){
				Magnet * magnet = (Magnet *) new LLGMagnet(magnetsIds[i], fReader);
				string magType = fReader->getItemProperty(DESIGN, magnetsIds[i], "myType");
				if(magType == "input"){
					this->circuit->addInputMagnet(magnet);
				} else if(magType == "output"){
					this->circuit->addOutputMagnet(magnet);
				}
				string clkZoneStr = fReader->getItemProperty(DESIGN, magnetsIds[i], "clockZone");
				if(clkZoneStr != "none"){
					this->circuit->addMagnetToZone(magnet, stoi(clkZoneStr));
				}
			}
		}
		break;
	}
}

void Simulation::buildNeighbors(){
	switch(this->mySimType){
		case THIAGO:
		case LLG:{
			vector <Magnet *> magnets = this->circuit->getAllMagnets();
			double neighborhoodRatio = stod(fReader->getProperty(CIRCUIT, "neighborhoodRatio"));
			for(int i=0; i<magnets.size(); i++){
				for(int j=i+1; j<magnets.size(); j++){
					magnets[i]->addNeighbor(magnets[j], &neighborhoodRatio);
					magnets[j]->addNeighbor(magnets[i], &neighborhoodRatio);
				}
			}
		}
		break;
	}
}