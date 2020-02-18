#include "ThiagoMagnet.h"

double ThiagoMagnet::neighborhoodRatio;

//This method splits a string into a vector of strings given a separator character
//This method exists because c++ string class has a lot of issues
vector<string> ThiagoMagnet::splitString(string str, char separator){
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

ThiagoMagnet::ThiagoMagnet(string id, FileReader * fReader){
	vector<string> vaux;
	string aux, compId;
	
	//Start the magnet build
	this->id = id;
	//Comp Id saves the component id of the magnet
	compId = fReader->getItemProperty(DESIGN, id, "component");
	//Gets the type and replace the string with the enum
	aux = fReader->getItemProperty(DESIGN, id, "myType");
	if(aux == "regular")
		this->myType = REGULAR;
	else if(aux == "input")
		this->myType = INPUT;
	else if(aux == "output")
		this->myType = OUTPUT;
	//Gets the fixed magnetization and replace it with a boolean with same value of the text
	aux = fReader->getItemProperty(DESIGN, id, "fixedMagnetization");
	this->fixedMagnetization = (aux == "true");
	//Gets the initial magnetization and sets the current magnetization and future magnetization to equal it
	this->magnetization = stod(fReader->getItemProperty(DESIGN, id, "magnetization"));
	this->tempMagnetization = magnetization;
	this->initialMagnetization = magnetization;
	//Gets the position, which is a vector and set the variables
	vaux = splitString(fReader->getItemProperty(DESIGN, id, "position"), ',');
	this->xPosition = stod(vaux[0]);
	this->yPosition = stod(vaux[1]);
	//Set the neighborhood radius
	ThiagoMagnet::neighborhoodRatio = stod(fReader->getProperty(CIRCUIT, "neighborhoodRatio"));
	//Make the magnet geometry
	double widht, height, thickness, topCut, bottomCut;
	widht = stod(fReader->getItemProperty(COMPONENTS, compId, "widht"));
	height = stod(fReader->getItemProperty(COMPONENTS, compId, "height"));
	thickness = stod(fReader->getItemProperty(COMPONENTS, compId, "thickness"));
	topCut = stod(fReader->getItemProperty(COMPONENTS, compId, "topCut"));
	bottomCut = stod(fReader->getItemProperty(COMPONENTS, compId, "bottomCut"));
	this->magnetizationCalculator = new LLGMagnetMagnetization(widht, height, thickness, topCut, bottomCut);

	//Has to compute demag tensor to proper initialize the LLGMagnetMagnetization class variables, which are needed in the future
	this->magnetizationCalculator->computeDemag();
}

double * ThiagoMagnet::getMagnetization(){
	return &this->magnetization;
}

void ThiagoMagnet::calculateMagnetization(ClockZone * zone){
	// The variable gaussian_value is the Gaussian-distributed random variable
	default_random_engine generator(chrono::system_clock::now().time_since_epoch().count());
	normal_distribution<double> distribution (0.0,1.0);
	double gaussian_value = distribution(generator);

	//If the variable is not an input or fixed...
	if(this->myType != INPUT && !this->fixedMagnetization){
		double aux = 0.0;
		//Compute the influence of the neighbors
		for(int i=0; i<this->neighbors.size(); i++){
			aux += *(this->neighbors[i]->getWeight()) * *(this->neighbors[i]->getMagnet()->getMagnetization());
		}

		//Adds the influence of the clock signal and the current magnetization
		double * signal = zone->getSignal();
		aux = (aux + this->magnetization) * (1.0 - signal[0]);
		free(signal);

		//Check the limits
		if(aux > 1.0){
			aux = 1.0;
		}
		if(aux < -1.0){
			aux = -1.0;
		}

		//Compute the thermal influence
		aux += THERMAL_ENERGY * gaussian_value;

		//Check the limits
		if(aux > 1.0){
			aux = 1.0;
		}
		if(aux < -1.0){
			aux = -1.0;
		}

		//Set the future magnetization
		this->tempMagnetization = aux;
	}
}

void ThiagoMagnet::updateMagnetization(){
	if(!this->fixedMagnetization)
		this->magnetization = this->tempMagnetization;
}

void ThiagoMagnet::dumpValues(ofstream * outFile){
	*outFile << this->magnetization << ",";
}

string ThiagoMagnet::getId(){
	return this->id;
}

void ThiagoMagnet::setMagnetization(double * magnetization){
	this->tempMagnetization = this->magnetization = *magnetization;
}

bool ThiagoMagnet::isNeighbor(ThiagoMagnet * magnet){
	//This method considers the diference of edges from the two magnets
	double * mpx = magnet->getPx();
	double * mpy = magnet->getPy();
	double xDiff, yDiff;
	xDiff = abs(this->xPosition - magnet->getXPosition()) - (mpx[1]-mpx[0]) - (getPx()[1] - getPx()[0]);
	yDiff = abs(this->yPosition - magnet->getYPosition()) - (mpy[0]-mpy[3]) - (getPy()[0] - getPy()[3]);
	double dist = sqrt(pow(xDiff, 2.0) + pow(yDiff, 2.0));
	return dist < this->neighborhoodRatio;
}

void ThiagoMagnet::addNeighbor(Magnet * neighbor, double * neighborhoodRatio){
	//If it is a neighbor
	if(this->isNeighbor(static_cast<ThiagoMagnet *> (neighbor))){
		//Distances between magnets
		double vDist = (this->yPosition - (static_cast<ThiagoMagnet *> (neighbor))->getYPosition());
		double hDist = (this->xPosition - (static_cast<ThiagoMagnet *> (neighbor))->getXPosition());
		//Neighbor px and py
		double * npx = (static_cast<ThiagoMagnet *> (neighbor))->getPx();
		double * npy = (static_cast<ThiagoMagnet *> (neighbor))->getPy();
		//Neighbor thickness
		double nt = (static_cast<ThiagoMagnet *> (neighbor))->getThickness();
		//Get the coupling tensor
		double * tensor = this->magnetizationCalculator->computeDipolar(npx, npy, nt, vDist, hDist);
		//Alloc memory for the weight and set to the component yy of the tensor
		double * aux = (double*)malloc(sizeof(double));
		*aux = tensor[4];
		//Create a new neighbor
		this->neighbors.push_back(new Neighbor(neighbor, aux));
	}
}

void ThiagoMagnet::normalizeWeights(){
	double big = 0;
	//Find the biggest tensor component
	for(int i=0; i<neighbors.size(); i++){
		double aux = *(neighbors[i]->getWeight());
		if(abs(aux) > big)
			big = abs(aux);
	}
	//Balance to correct the antiferromagnetic coupling
	big *= -1;
	//Normalize all tensors to become weights
	for(int i=0; i<neighbors.size(); i++){
		double * aux = (double*)malloc(sizeof(double));
		*aux = *(neighbors[i]->getWeight());
		*aux = *aux/big;
		neighbors[i]->updateWeight(aux);
	}
}

double * ThiagoMagnet::getPx(){
	return this->magnetizationCalculator->getPx();
}

double * ThiagoMagnet::getPy(){
	return this->magnetizationCalculator->getPy();
}

double ThiagoMagnet::getThickness(){
	return this->magnetizationCalculator->getThickness();
}

double ThiagoMagnet::getXPosition(){
	return this->xPosition;
}

double ThiagoMagnet::getYPosition(){
	return this->yPosition;
}

void ThiagoMagnet::resetMagnetization(){
	this->magnetization = this->initialMagnetization;
}

void ThiagoMagnet::makeHeader(ofstream * outFile){
	*(outFile) << this->id << "_y,";
}

vector <Neighbor *> ThiagoMagnet::getNeighbors(){
	return this->neighbors;
}