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

Simulation::Simulation(string singlePath){
	singlePath = splitString(singlePath, '.')[0];
	this->fReader = new FileReader(singlePath + ".xml");
	this->currentTime = 0.0;
	this->deltaTime = stod(fReader->getProperty(CIRCUIT, "timeStep"));
	this->simulationDuration = stod(fReader->getProperty(CIRCUIT, "simTime"));
	this->mySimType = fReader->getEngine();
	this->mySimMode = fReader->getSimMode();
	this->outFile.open(getFileName(singlePath));
	buildClkCtrl();
	buildCircuit();
}

string Simulation::getFileName(string initial){
	ifstream aux(initial + ".csv");
	if(aux.fail())
		return initial + ".csv";
	for(int i=2; true; i++){
		ifstream aux2(initial + "_" + to_string(i) + ".csv");
		if(aux2.fail())
			return (initial + "_" + to_string(i) + ".csv");
	}
}

void Simulation::verboseSimulation(double reportDeltaTime){
	double auxTimer = 0.0;
	outFile << "Time,";
	this->circuit->makeHeader(&outFile);
	outFile << endl;
	outFile << currentTime << ",";
	this->circuit->dumpMagnetsValues(&outFile);
	outFile << endl;
	while(this->currentTime < this->simulationDuration){
		auxTimer += this->deltaTime;
		this->circuit->nextTimeStep();
		this->currentTime += this->deltaTime;
		if(auxTimer >= reportDeltaTime){
			outFile << currentTime << ",";
			this->circuit->dumpMagnetsValues(&outFile);
			outFile << endl;
			auxTimer = 0.0;
		}
	}
}

void Simulation::exaustiveSimulation(){
	int inputSize = circuit->getInputsSize();
	int limit = (int) pow(2.0, (double) inputSize);
	cout << "Progress: 0%\n";
	for(int i=0; i<limit; i++){
		outFile << "COMBINATION " << i << endl << "Initial Value\n";
		circuit->setInputs(i, this->mySimType);
		this->circuit->dumpInOutValues(&outFile);
		outFile << endl;
		this->currentTime = 0.0;
		circuit->restartAllPhases();
		while(this->currentTime < this->simulationDuration){
			this->circuit->nextTimeStep();
			this->currentTime += this->deltaTime;
		}
		outFile << "End Value\n";
		this->circuit->dumpInOutValues(&outFile);
		outFile << endl << endl;
		circuit->resetZonesPhases();
		cout << "\033[1A" << "\033[K";
		cout << "Progress: " << ((double) (i+1) * 100.0)/ (double)limit << "%\n";
	}
}

void Simulation::directSimulation(){
	while(this->currentTime < this->simulationDuration){
		this->circuit->nextTimeStep();
		this->currentTime += this->deltaTime;
	}
	this->circuit->makeHeader(&outFile);
	outFile << endl;
	this->circuit->dumpMagnetsValues(&outFile);
	outFile << endl;
}

void Simulation::repetitiveSimulation(){
	int repetitions = stod(fReader->getProperty(CIRCUIT, "repetitions"));
	outFile << "Repetition,";
	this->circuit->makeHeader(&outFile);
	outFile << endl;
	cout << "Progress: 0%\n";
	for(int i=0; i<repetitions; i++){
		outFile << i << ",";
		while(this->currentTime < this->simulationDuration){
			this->circuit->nextTimeStep();
			this->currentTime += this->deltaTime;
		}
		this->circuit->dumpMagnetsValues(&outFile);
		outFile << endl;
		this->currentTime = 0;
		circuit->restartAllPhases();
		circuit->resetZonesPhases();
		circuit->restartAllMagnets();
		cout << "\033[1A" << "\033[K";
		cout << "Progress: " << ((double) (i+1) * 100.0)/ (double)repetitions << "%\n";
	}
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
		case REPETITIVE:{
			repetitiveSimulation();
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
				double * initial, * end, * variation, duration;
				initial = (double*)malloc(1*sizeof(double));
				end = (double*)malloc(1*sizeof(double));
				variation = (double*)malloc(1*sizeof(double));
				initial[0] = stod(fReader->getItemProperty(PHASE, aux[i], "initialSignal"));
				end[0] = stod(fReader->getItemProperty(PHASE, aux[i], "endSignal"));
				duration = stod(fReader->getItemProperty(PHASE, aux[i], "duration"));
				variation[0] = (end[0] - initial[0])/(duration/deltaTime);
				ClockPhase * phaseAux = new ClockPhase(aux[i], duration, initial, end, variation, 1);
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
				double * initial, * end, * variation, duration;
				initial = (double*)malloc(6*sizeof(double));
				end = (double*)malloc(6*sizeof(double));
				variation = (double*)malloc(6*sizeof(double));
				parts = splitString(fReader->getItemProperty(PHASE, aux[i], "initialSignal"), ',');
				for(int j=0; j<6; j++){
					initial[j] = stod(parts[j]);
				}
				parts = splitString(fReader->getItemProperty(PHASE, aux[i], "endSignal"), ',');
				for(int j=0; j<6; j++){
					end[j] = stod(parts[j]);
				}
				duration = stod(fReader->getItemProperty(PHASE, aux[i], "duration"));
				for(int j=0; j<6; j++){
					variation[j] = (end[j] - initial[j])/(duration/deltaTime);
				}
				ClockPhase * phaseAux = new ClockPhase(aux[i], duration, initial, end, variation, 6);
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
		case THIAGO:{
			vector <Magnet *> magnets = this->circuit->getAllMagnets();
			double neighborhoodRatio = stod(fReader->getProperty(CIRCUIT, "neighborhoodRatio"));
			for(int i=0; i<magnets.size(); i++){
				for(int j=i+1; j<magnets.size(); j++){
					magnets[i]->addNeighbor(magnets[j], &neighborhoodRatio);
					magnets[j]->addNeighbor(magnets[i], &neighborhoodRatio);
				}
			}
			for(int i=0; i<magnets.size(); i++)
				(static_cast<ThiagoMagnet *> (magnets[i]))->normalizeWeights();
		}
		break;
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