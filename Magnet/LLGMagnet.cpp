#include "LLGMagnet.h"

double LLGMagnet::alpha;
double LLGMagnet::alpha_l;
double LLGMagnet::Ms;
double LLGMagnet::temperature;
double LLGMagnet::timeStep;
double LLGMagnet::v [3];
double LLGMagnet::dt;
double LLGMagnet::dW [3];

vector<string> LLGMagnet::splitString(string str, char separator){
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

LLGMagnet::LLGMagnet(string id, FileReader * fReader){
	//Basic constants
	this->id = id;
	this->alpha = stod(fReader->getProperty(CIRCUIT, "alpha"));
	this->Ms = stod(fReader->getProperty(CIRCUIT, "Ms"));
	this->temperature = stod(fReader->getProperty(CIRCUIT, "temperature"));
	this->timeStep = stod(fReader->getProperty(CIRCUIT, "timeStep"))*pow(10.0, -9.0);

	string compName = fReader->getItemProperty(DESIGN, id, "component");

	//Initial magnetization
	vector<string> parts;
	parts = splitString(fReader->getItemProperty(DESIGN, id, "magnetization"), ',');
	for(int i=0; i<3; i++)
		this->magnetization[i] = stod(parts[i]);

	//Fixed magnetization
	this->fixedMagnetization = (fReader->getItemProperty(COMPONENTS, compName, "fixedMagnetization") == "true");

	//Geometry
	double px[4], py[4], thickness;
	for(int i=0; i<4; i++){
		parts = splitString(fReader->getItemProperty(COMPONENTS, compName, "P"+to_string(i)), ',');
		px[i] = stod(parts[0]);
		py[i] = stod(parts[1]);
	}
	thickness = stod(fReader->getItemProperty(COMPONENTS, compName, "thickness"));
	this->magnetizationCalculator = new LLGMagnetMagnetization(px, py, thickness);

	//Position
	parts = splitString(fReader->getItemProperty(DESIGN, id, "position"), ',');
	this->xPosition = stod(parts[0]);
	this->yPosition = stod(parts[1]);

	//Calculate the demag energy
	double ** auxND = this->magnetizationCalculator->computeDemag();
	for(int i=0; i<3; i++){
		for(int j=0; j<3; j++){
			nd[i][j] = auxND[i][j];
		}
	}

	this->volume = this->magnetizationCalculator->getVolume();
	initializeConstants();
}

void LLGMagnet::initializeConstants(){
	this->alpha_l = 1.0/(1+pow(this->alpha, 2.0));
	this->dt = this->timeStep*gammamu0*this->Ms;
	for(int i=0; i<3; i++){
		this->v[i] = sqrt((2.0*this->alpha*kb*this->temperature) / (gammamu0*mu0*this->Ms*(this->volume * pow(10.0, -27.0))*this->timeStep))
					*(sqrt(this->dt)/this->Ms);
	}
}

void LLGMagnet::crossProduct(double *vect_A, double *vect_B, double *cross_P){
    cross_P[0] = vect_A[1] * vect_B[2] - vect_A[2] * vect_B[1];
    cross_P[1] = vect_A[2] * vect_B[0] - vect_A[0] * vect_B[2];
    cross_P[2] = vect_A[0] * vect_B[1] - vect_A[1] * vect_B[0];
}
 
void LLGMagnet::calculateMagnetization(ClockPhase * phase){	
	double hd[3], hc[3] = {0.0,0.0,0.0}, heff[3];
	double m_heff[3], mm_heff[3], a[3];
	double m_v[3], mm_v[3], b[3];

	//##################################### DANGER!!! #################################
	//Could be wrong while usign a cutted particle (maybe transpose the nd)
	for(int i=0; i<3; i++)
		hd[i] = 
			(this->magnetization[0]*nd[0][i] + 
			this->magnetization[1]*nd[1][i] + 
			this->magnetization[2]*nd[2][i])*-1.0;

	for(int j=0; j<this->neighbors.size(); j++){
		for(int i=0; i<3; i++)
			hc[i] += 
				(neighbors[j]->getMagnet()->getMagnetization()[0]*(this->neighbors[j]->getWeight()[i]) + 
				neighbors[j]->getMagnet()->getMagnetization()[1]*(this->neighbors[j]->getWeight()[i+3]) + 
				neighbors[j]->getMagnet()->getMagnetization()[2]*(this->neighbors[j]->getWeight()[i+6]))*-1.0;
	}

	if(LLGMagnet::temperature == 0){
		double k1[3], k2[3], k3[3], k4[3], auxSig[3], auxVar[3], auxMag[3];
		for(int i=0; i<3; i++){
			auxSig[i] = phase->getSignal()[i];
			auxVar[i] = phase->getVariation()[i];
		}

		f_term(this->magnetization, auxSig, hd, hc, k1);
		for(int i=0; i<3; i++)
			k1[i] *= this->dt;
		
		for(int i=0; i<3; i++)
			auxSig[i] += auxVar[i]/2;
		for(int i=0; i<3; i++)
			auxMag[i] = this->magnetization[i] + k1[i]/2;
		f_term(auxMag, auxSig, hd, hc, k2);
		for(int i=0; i<3; i++)
			k2[i] *= this->dt;
		
		for(int i=0; i<3; i++)
			auxMag[i] = this->magnetization[i] + k2[i]/2;
		f_term(auxMag, auxSig, hd, hc, k3);
		for(int i=0; i<3; i++)
			k3[i] *= this->dt;
		
		for(int i=0; i<3; i++)
			auxSig[i] += auxVar[i]/2;
		for(int i=0; i<3; i++)
			auxMag[i] = this->magnetization[i] + k3[i];
		f_term(this->magnetization, auxSig, hd, hc, k4);
		for(int i=0; i<3; i++)
			k4[i] *= this->dt;

		for(int i=0; i<3; i++)
			this->newMagnetization[i] = this->magnetization[i] + (k1[i] + 2*k2[i] + 2*k3[i] + k4[i])/6;
	} else{
		for(int i=0; i<3; i++){
			if(this->fixedMagnetization)
				heff[i] = hd[i] + hc[i];
			else{
				heff[i] = phase->getSignal()[i] / (mu0 * 1000.0 * this->Ms) + hd[i] + hc[i];
			}
		}

		crossProduct(this->magnetization, heff, m_heff);
		crossProduct(this->magnetization, m_heff, mm_heff);

		for(int i=0; i<3; i++){
			a[i] = -1.0*this->alpha_l*(
				m_heff[i] + this->alpha*mm_heff[i]
				) + (
				alpha_l * pow(v[i], 2.0) * this->magnetization[i]
				);
		}

		crossProduct(this->magnetization, this->v, m_v);
		crossProduct(this->magnetization, m_v, mm_v);

		for(int i=0; i<3; i++){
			b[i] = -1.0*this->alpha_l*(
				m_v[i]+this->alpha*mm_v[i]
				);
		}

		if(this->firstIteration)
			this->firstIteration = false;
		else{
			default_random_engine generator(chrono::system_clock::now().time_since_epoch().count());
			normal_distribution<double> distribution (0.0,1.0);
			this->dW[0] = distribution(generator);
			this->dW[1] = distribution(generator);
			this->dW[2] = distribution(generator);

		}

		for(int i=0; i<3; i++){
			this->newMagnetization[i] = this->magnetization[i] + a[i]*this->dt + b[i]*this->dW[i];
		}
	}
}

void LLGMagnet::f_term(double * currMag, double * currSignal, double* hd, double* hc, double * result){
	double heff[3], m_heff[3], mm_heff[3];
	double m_v[3], mm_v[3], b[3];

	for(int i=0; i<3; i++){
		if(this->fixedMagnetization)
			heff[i] = hd[i] + hc[i];
		else{
			heff[i] = currSignal[i] / (mu0 * 1000.0 * this->Ms) + hd[i] + hc[i];
		}
	}

	crossProduct(currMag, heff, m_heff);
	crossProduct(currMag, m_heff, mm_heff);

	for(int i=0; i<3; i++){
		result[i] = -1.0*this->alpha_l*(
			m_heff[i] + this->alpha*mm_heff[i]
			);
	}
}

double * LLGMagnet::getMagnetization(){
	return this->magnetization;
}

void LLGMagnet::updateMagnetization(){
	double module = sqrt(pow(this->newMagnetization[0], 2.0) + pow(this->newMagnetization[1], 2.0) + pow(this->newMagnetization[2], 2.0));
	this->magnetization[0] = this->newMagnetization[0]/module;
	this->magnetization[1] = this->newMagnetization[1]/module;
	this->magnetization[2] = this->newMagnetization[2]/module;
}

void LLGMagnet::addNeighbor(Magnet * neighbor, double * ratio){
	if(this->isNeighbor(static_cast<LLGMagnet *> (neighbor), *ratio)){
		double vDist = (this->yPosition - (static_cast<LLGMagnet *> (neighbor))->getYPosition());
		double hDist = (this->xPosition - (static_cast<LLGMagnet *> (neighbor))->getXPosition());
		double * npx = (static_cast<LLGMagnet *> (neighbor))->getPx();
		double * npy = (static_cast<LLGMagnet *> (neighbor))->getPy();
		double nt = (static_cast<LLGMagnet *> (neighbor))->getThickness();
		double * tensor = this->magnetizationCalculator->computeDipolar(npx, npy, nt, vDist, hDist);
		this->neighbors.push_back(new Neighbor(neighbor, tensor));
	}
}

void LLGMagnet::dumpValues(ofstream * out){
	*(out) << this->magnetization[0] << ",";
	*(out) << this->magnetization[1] << ",";
	*(out) << this->magnetization[2] << ",";
}

string LLGMagnet::getId(){
	return this->id;
}

void LLGMagnet::setMagnetization(double * magnetization){
	this->magnetization[0] = magnetization[0];
	this->magnetization[1] = magnetization[1];
	this->magnetization[2] = magnetization[2];
}

double * LLGMagnet::getPx(){
	return this->magnetizationCalculator->getPx();
}

double * LLGMagnet::getPy(){
	return this->magnetizationCalculator->getPy();
}

double LLGMagnet::getThickness(){
	return this->magnetizationCalculator->getThickness();
}

double LLGMagnet::getXPosition(){
	return this->xPosition;
}

double LLGMagnet::getYPosition(){
	return this->yPosition;
}

bool LLGMagnet::isNeighbor(LLGMagnet * magnet, double ratio){
	double * mpx = magnet->getPx();
	double * mpy = magnet->getPy();
	double xDiff, yDiff;
	xDiff = abs(this->xPosition - magnet->getXPosition()) - (mpx[1]-mpx[0]) - (getPx()[1] - getPx()[0]);
	yDiff = abs(this->yPosition - magnet->getYPosition()) - (mpy[0]-mpy[3]) - (getPy()[0] - getPy()[3]);
	double dist = sqrt(pow(xDiff, 2.0) + pow(yDiff, 2.0));
	return dist < ratio;
}