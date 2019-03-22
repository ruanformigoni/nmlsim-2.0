#include "ThiagoMagnet.h"

double ThiagoMagnet::neighborhoodRatio;

vector<string> ThiagoMagnet::splitString(string str, char separator){
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

ThiagoMagnet::ThiagoMagnet(string id, FileReader * fReader){
	vector<string> vaux;
	string aux, compId;
	this->id = id;
	aux = fReader->getItemProperty(DESIGN, id, "myType");
	compId = fReader->getItemProperty(DESIGN, id, "component");
	if(aux == "regular")
		this->myType = REGULAR;
	else if(aux == "input")
		this->myType = INPUT;
	else if(aux == "output")
		this->myType = OUTPUT;
	aux = fReader->getItemProperty(COMPONENTS, compId, "fixedMagnetization");
	this->fixedMagnetization = (aux == "true");
	this->magnetization = stod(fReader->getItemProperty(DESIGN, id, "magnetization"));
	this->tempMagnetization = magnetization;
	vaux = splitString(fReader->getItemProperty(DESIGN, id, "position"), ',');
	this->xPosition = stod(vaux[0]);
	this->yPosition = stod(vaux[1]);
	ThiagoMagnet::neighborhoodRatio = stod(fReader->getProperty(CIRCUIT, "neighborhoodRatio"));
	double px[4], py[4], t;
	for(int i=0; i<4; i++){
		vaux = splitString(fReader->getItemProperty(COMPONENTS, compId, "P"+to_string(i)), ',');
		px[i] = stod(vaux[0]);
		py[i] = stod(vaux[1]);
	}
	t = stod(fReader->getItemProperty(COMPONENTS, compId, "thickness"));
	this->magnetizationCalculator = new LLGMagnetMagnetization(px, py, t);
}

double * ThiagoMagnet::getMagnetization(){
	return &this->magnetization;
}

void ThiagoMagnet::calculateMagnetization(ClockPhase * phase){
	// The variable gaussian_value is the Gaussian-distributed random variable
	default_random_engine generator(chrono::system_clock::now().time_since_epoch().count());
	normal_distribution<double> distribution (0.0,1.0);
	double gaussian_value = distribution(generator);

	if(this->myType != INPUT && !this->fixedMagnetization){
		double aux = 0.0;
		for(int i=0; i<this->neighbors.size(); i++){
			aux += *(this->neighbors[i]->getWeight()) * *(this->neighbors[i]->getMagnet()->getMagnetization());
		}

		aux = (aux + this->magnetization) * (1.0 - phase->getSignal()[1]);

		if(aux > 1.0){
			aux = 1.0;
		}
		if(aux < -1.0){
			aux = -1.0;
		}

		aux += THERMAL_ENERGY * gaussian_value;

		if(aux > 1.0){
			aux = 1.0;
		}
		if(aux < -1.0){
			aux = -1.0;
		}

		this->tempMagnetization = aux;
	}
}

void ThiagoMagnet::updateMagnetization(){
	if(!this->fixedMagnetization)
		this->magnetization = this->tempMagnetization;
}

void ThiagoMagnet::dumpValues(ofstream * outFile){
	*(outFile) << "Id: " << this->id << " ";
	*(outFile) << "type: " << ((this->myType == 0)?"input":(this->myType == 1)?"output":"regular") << " ";
	*(outFile) << "fixedMag: " << ((this->fixedMagnetization)?"T":"F") << " ";
	*(outFile) << "mag: " << this->magnetization << endl;
}

string ThiagoMagnet::getId(){
	return this->id;
}

void ThiagoMagnet::setMagnetization(double * magnetization){
	this->tempMagnetization = this->magnetization = *magnetization;
}

bool ThiagoMagnet::isNeighbor(ThiagoMagnet * magnet){
	double * mpx = magnet->getPx();
	double * mpy = magnet->getPy();
	double xDiff, yDiff;
	xDiff = abs(this->xPosition - magnet->getXPosition()) - (mpx[1]-mpx[0]) - (getPx()[1] - getPx()[0]);
	yDiff = abs(this->yPosition - magnet->getYPosition()) - (mpy[0]-mpy[3]) - (getPy()[0] - getPy()[3]);
	double dist = sqrt(pow(xDiff, 2.0) + pow(yDiff, 2.0));
	return dist < this->neighborhoodRatio;
}

void ThiagoMagnet::addNeighbor(Magnet * neighbor, double * neighborhoodRatio){
	if(this->isNeighbor(static_cast<ThiagoMagnet *> (neighbor))){
		double vDist = (this->yPosition - (static_cast<ThiagoMagnet *> (neighbor))->getYPosition());
		double hDist = (this->xPosition - (static_cast<ThiagoMagnet *> (neighbor))->getXPosition());
		double * npx = (static_cast<ThiagoMagnet *> (neighbor))->getPx();
		double * npy = (static_cast<ThiagoMagnet *> (neighbor))->getPy();
		double nt = (static_cast<ThiagoMagnet *> (neighbor))->getThickness();
		double * tensor = this->magnetizationCalculator->computeDipolar(npx, npy, nt, vDist, hDist);
		this->neighbors.push_back(new Neighbor(neighbor, &tensor[4]));
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
