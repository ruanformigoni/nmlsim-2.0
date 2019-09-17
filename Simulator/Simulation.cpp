#include "Simulation.h"

Simulation::Simulation(string filePath, string outFilePath){
	this->fReader = new FileReader(filePath);
	this->currentTime = 0.0;
	this->deltaTime = stod(fReader->getProperty(CIRCUIT, "timeStep"));
	this->simulationDuration = stod(fReader->getProperty(CIRCUIT, "simTime"));
	this->mySimType = fReader->getEngine();
	this->mySimMode = fReader->getSimMode();
	this->outFile.open(outFilePath.c_str());

	buildClkCtrl();
	buildCircuit();
}

Simulation::Simulation(string singlePath){
	//Removes the extension from the file
	singlePath = singlePath.substr(0,singlePath.length()-4);

	this->fReader = new FileReader(singlePath + ".xml");
	this->currentTime = 0.0;
	this->deltaTime = stod(fReader->getProperty(CIRCUIT, "timeStep"));
	this->simulationDuration = stod(fReader->getProperty(CIRCUIT, "simTime"));
	this->mySimType = fReader->getEngine();
	this->mySimMode = fReader->getSimMode();
	this->outFile.open(getFileName(singlePath).c_str());
	
	buildClkCtrl();
	buildCircuit();
}

string Simulation::getFileName(string initial){
	ifstream aux(initial + ".csv");
	//If there isn't a file with same name and extensio csv
	if(aux.fail())
		return initial + ".csv";
	//It there is, add an _#, where # is the next available number for a file name
	for(int i=2; true; i++){
		ifstream aux2(initial + "_" + to_string(i) + ".csv");
		if(aux2.fail())
			return (initial + "_" + to_string(i) + ".csv");
	}
}

void Simulation::verboseSimulation(double reportDeltaTime){
	double auxTimer = 0.0;
	cout << "Starting verbose simulation...\n";
	outFile << "Time,";
	
	//Write the output file header
	this->circuit->makeHeader(&outFile);
	outFile << endl;
	//Print the values for time = 0
	outFile << currentTime << ",";
	this->circuit->dumpMagnetsValues(&outFile);
	outFile << endl;

	//While the simulation does not reach the end...
	while(this->currentTime < this->simulationDuration){
		//Update auxiliar timer, which is used to check the report time step
		auxTimer += this->deltaTime;
		//Simulate next time step
		this->circuit->nextTimeStep();
		//Update timer
		this->currentTime += this->deltaTime;
		//Dump values in case the report step is reached
		if(auxTimer >= reportDeltaTime){
			outFile << currentTime << ",";
			this->circuit->dumpMagnetsValues(&outFile);
			outFile << endl;
			auxTimer = 0.0;
		}
	}
}

void Simulation::exaustiveSimulation(){
	//Compute the number of combinations for exaustive simulation
	int inputSize = circuit->getInputsSize();
	int limit = (int) pow(2.0, (double) inputSize);
	//Print progress
	cout << "Progress: 0%\n";
	for(int i=0; i<limit; i++){
		//Dump in the output file
		outFile << "COMBINATION " << i << endl << "Initial Value\n";
		//Set the input with the index as a bitmask
		circuit->setInputs(i, this->mySimType);
		//Dump input and output values at time 0
		this->circuit->dumpInOutValues(&outFile);
		outFile << endl;
		//Reset the circuit
		this->currentTime = 0;
		circuit->restartAllPhases();
		circuit->resetZonesPhases();
		circuit->restartAllMagnets();
		//Simulate
		while(this->currentTime < this->simulationDuration){
			this->circuit->nextTimeStep();
			this->currentTime += this->deltaTime;
		}
		//Dump input and output values at time MAX
		outFile << "End Value\n";
		this->circuit->dumpInOutValues(&outFile);
		outFile << endl << endl;
		circuit->resetZonesPhases();
		//Erase progress line and print the new progress
		cout << "\033[1A" << "\033[K";
		cout << "Progress: " << ((double) (i+1) * 100.0)/ (double)limit << "%\n";
	}
}

void Simulation::directSimulation(){
	cout << "Starting direct simulation...\n";
	//Simulate
	while(this->currentTime < this->simulationDuration){
		this->circuit->nextTimeStep();
		this->currentTime += this->deltaTime;
	}
	//Dump result
	this->circuit->makeHeader(&outFile);
	outFile << endl;
	this->circuit->dumpMagnetsValues(&outFile);
	outFile << endl;
}

void Simulation::repetitiveSimulation(){
	//Get number of repetitions
	int repetitions = stod(fReader->getProperty(CIRCUIT, "repetitions"));
	//Build header
	outFile << "Repetition,";
	this->circuit->makeHeader(&outFile);
	outFile << endl;
	//Print prorgess
	cout << "Progress: 0%\n";
	for(int i=0; i<repetitions; i++){
		outFile << i << ",";
		//Simulate
		while(this->currentTime < this->simulationDuration){
			this->circuit->nextTimeStep();
			this->currentTime += this->deltaTime;
		}
		//Dump results
		this->circuit->dumpMagnetsValues(&outFile);
		outFile << endl;
		//Reset simulation
		this->currentTime = 0;
		circuit->restartAllPhases();
		circuit->resetZonesPhases();
		circuit->restartAllMagnets();
		//Erase progress line and print the new progress
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
	cout << "Starting building clock controller...\n";
	switch(this->mySimType){
		case THIAGO:{
			//Variables for creating zones and phases
			vector<ClockPhase *> phases;
			vector<ClockZone *> zones;

			//Auxiliar vectors
			vector <string> aux;
			vector <string> parts;
			string value;

			//Creating the phases
			aux = fReader->getItems(PHASE);
			//For each item...
			for(int i=0; i<aux.size(); i++){
				double * initial, * end, * variation, duration;
				//Alloc initial, end and variation values
				initial = (double*)malloc(1*sizeof(double));
				end = (double*)malloc(1*sizeof(double));
				variation = (double*)malloc(1*sizeof(double));
				//Get initial, end and variation signals
				initial[0] = stod(fReader->getItemProperty(PHASE, aux[i], "initialSignal"));
				end[0] = stod(fReader->getItemProperty(PHASE, aux[i], "endSignal"));
				duration = stod(fReader->getItemProperty(PHASE, aux[i], "duration"));	//Get the duration
				variation[0] = (end[0] - initial[0])/(duration/deltaTime);

				//Build the clock phase
				ClockPhase * phaseAux = new ClockPhase(aux[i], duration, initial, end, variation, 1);
				phases.push_back(phaseAux);
			}

			//Creating the zones
			aux = fReader->getItems(ZONE);
			//For each zone
			for(int i=0; i<aux.size(); i++){
				//Get all phases of the zone
				parts = fReader->getAllItemProperties(ZONE, aux[i]);
				ClockPhase * phaseAux;	//Initial phase
				//Find initial phase
				for(int j=0; j<phases.size(); j++){
					if(phases[j]->getPhaseName() == parts[0]){
						phaseAux = phases[j];
					}
				}

				//Build the zone
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

			//Auxiliar vectors
			vector <string> aux;
			vector <string> parts;

			//Creating the phases
			aux = fReader->getItems(PHASE);
			for(int i=0; i<aux.size(); i++){
				double * initial, * end, * variation, duration;
				//Alloc initial, end and variation values
				initial = (double*)malloc(6*sizeof(double));
				end = (double*)malloc(6*sizeof(double));
				variation = (double*)malloc(6*sizeof(double));
				parts = splitString(fReader->getItemProperty(PHASE, aux[i], "initialSignal"), ',');
				//Get initial, end and variation signals
				for(int j=0; j<6; j++){
					initial[j] = stod(parts[j]);
				}
				parts = splitString(fReader->getItemProperty(PHASE, aux[i], "endSignal"), ',');
				for(int j=0; j<6; j++){
					end[j] = stod(parts[j]);
				}
				duration = stod(fReader->getItemProperty(PHASE, aux[i], "duration"));	//Get the duration
				for(int j=0; j<6; j++){
					variation[j] = (end[j] - initial[j])/(duration/deltaTime);
				}

				//Build the phase
				ClockPhase * phaseAux = new ClockPhase(aux[i], duration, initial, end, variation, 6);
				phases.push_back(phaseAux);
			}

			//Creating the zones
			aux = fReader->getItems(ZONE);
			//For each zone
			for(int i=0; i<aux.size(); i++){
				//Get all phases of the zone
				parts = fReader->getAllItemProperties(ZONE, aux[i]);
				ClockPhase * phaseAux;
				//Find initial phase
				for(int j=0; j<phases.size(); j++){
					if(phases[j]->getPhaseName() == parts[0]){
						phaseAux = phases[j];
					}
				}

				//Build the zone
				zones.push_back(new ClockZone(phaseAux, parts));
			}

			//Creating the circuit
			this->circuit = new Circuit(zones, phases, this->deltaTime);
		}
		break;
	}
	cout << "Finished building clock controller!\n";
}

//This method splits a string into a vector of strings given a separator character
//This method exists because c++ string class has a lot of issues
vector<string> Simulation::splitString(string str, char separator){
	vector<string> parts;	//Return parts
	int startIndex = 0;	//Start index of the substrings
	for(int i=0; i<str.size(); i++){
		//If a separator character is found or the index reach the end of the string
		if(str[i] == separator || i == str.size()-1){
			//If the index is not the end of the string, skip the separator character
			if(i == str.size()-1)
				i++;
			//Add the new part to the vector
			parts.push_back(str.substr(startIndex, i-startIndex));
			//Update the start index
			startIndex = i+1;
		}
	}
	return parts;
}

void Simulation::buildCircuit(){
	cout << "Computing the demag tensors...\n";
	buildMagnets();
	cout << "Demag tensors done!\nComputing dipolar tensors...\n";
	buildNeighbors();
	cout << "Dipolar tensors done!\n";
}

void Simulation::buildMagnets(){
	switch(this->mySimType){
		case THIAGO:{
			//Get all magnets items from XML file
			vector<string> magnetsIds = fReader->getItems(DESIGN);
			//For each magnet
			for(int i=0; i<magnetsIds.size(); i++){
				//Build the new magnet
				Magnet * magnet = (Magnet *) new ThiagoMagnet(magnetsIds[i], fReader);
				//Check if the type is input, output or regular
				string magType = fReader->getItemProperty(DESIGN, magnetsIds[i], "myType");
				if(magType == "input"){
					//Add to input list
					this->circuit->addInputMagnet(magnet);
				} else if(magType == "output"){
					//Add to output list
					this->circuit->addOutputMagnet(magnet);
				}
				//Get the clock zone and add it
				string clkZoneStr = fReader->getItemProperty(DESIGN, magnetsIds[i], "clockZone");
				if(clkZoneStr != "none"){
					this->circuit->addMagnetToZone(magnet, stoi(clkZoneStr));
				}
			}
		}
		break;
		case LLG:{
			//Get all magnets items from XML file
			vector<string> magnetsIds = fReader->getItems(DESIGN);
			//For each magnet
			for(int i=0; i<magnetsIds.size(); i++){
				//Build the new magnet
				Magnet * magnet = (Magnet *) new LLGMagnet(magnetsIds[i], fReader);
				//Check if there is a mimic and add it
				string mimicId = fReader->getItemProperty(DESIGN, magnetsIds[i], "mimic");
				if(mimicId != ""){
					(static_cast<LLGMagnet *> (magnet))->setMimic(circuit->getMagnet(mimicId));
				}
				//Check if the type is input, output or regular
				string magType = fReader->getItemProperty(DESIGN, magnetsIds[i], "myType");
				if(magType == "input"){
					//Add to input list
					this->circuit->addInputMagnet(magnet);
				} else if(magType == "output"){
					//Add to output list
					this->circuit->addOutputMagnet(magnet);
				}
				//Get the clock zone and add it
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
			//Get all magnets
			vector <Magnet *> magnets = this->circuit->getAllMagnets();
			//Get neighborhood RADIUS (misspelled here)
			double neighborhoodRatio = stod(fReader->getProperty(CIRCUIT, "neighborhoodRatio"));
			//Double loop to compare magnets pair to pair
			for(int i=0; i<magnets.size(); i++){
				for(int j=i+1; j<magnets.size(); j++){
					//Add each other as neighbors in case they are
					magnets[i]->addNeighbor(magnets[j], &neighborhoodRatio);
					magnets[j]->addNeighbor(magnets[i], &neighborhoodRatio);
				}
			}
			//Normalize the weights
			for(int i=0; i<magnets.size(); i++)
				(static_cast<ThiagoMagnet *> (magnets[i]))->normalizeWeights();
		}
		break;
		case LLG:{
			//Get all magnets
			vector <Magnet *> magnets = this->circuit->getAllMagnets();
			//Get neighborhood RADIUS (misspelled here)
			double neighborhoodRatio = stod(fReader->getProperty(CIRCUIT, "neighborhoodRatio"));
			//Double loop to compare magnets pair to pair
			for(int i=0; i<magnets.size(); i++){
				for(int j=i+1; j<magnets.size(); j++){
					//Add each other as neighbors in case they are
					magnets[i]->addNeighbor(magnets[j], &neighborhoodRatio);
					magnets[j]->addNeighbor(magnets[i], &neighborhoodRatio);
				}
			}
		}
		break;
	}
}

//Load the tensor library
void Simulation::verifyTensorsMap(string filePath){
	//Create the file if it doesn't exists
	demagLog.open(filePath.c_str(), fstream::app);
	//Open the file
	ifstream demagContent(filePath.c_str());

	if (demagContent.is_open()){
		string line;
		//Get all lines one by one
		while(getline(demagContent, line)){
			//Get the indexes for each part of the line
			int colonIndex = line.find(":");
			string key = line.substr(0,colonIndex);
			string volAndTensors = line.substr(colonIndex+1,line.size());
			colonIndex = volAndTensors.find(":");
			
			//Get the volume
			double vol = stod(volAndTensors.substr(0,colonIndex));
			//Get the tensors string
			string tensors = volAndTensors.substr(colonIndex+1,volAndTensors.size());
			
			//If the key is not in the hash already
			if (demagBib.find(key) == demagBib.end()){   
				double **retValues = (double **)malloc(3 * sizeof(double *));
				for (int i = 0; i < 3; i++)
					retValues[i] = (double *)malloc(3 * sizeof(double));

				vector<double> values;
				int commaIndex = tensors.find(",");
				int begin = 0;
				
				string novo = tensors;
				
				while(commaIndex > 0){
					values.push_back(stod(novo.substr(begin, commaIndex)));
					novo = novo.substr(commaIndex + 1, novo.size());
					commaIndex = novo.find(",");
				}

				for (int i = 0; i < 3; i++){
					for (int y = 0; y < 3; y++){
						retValues[i][y] = values[i * 3 + y];
					}
				}

				volumeBib[key] = vol;
				demagBib[key] = retValues;
			}
		}
	} else{
		cout << "Unable to open the demag file!";
	}
	//Close demag file
	demagContent.close();
}