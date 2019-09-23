#include "LLGMagnet.h"

//Forward declaration of static variables
double LLGMagnet::alpha;
double LLGMagnet::alpha_l;
double LLGMagnet::Ms;
double LLGMagnet::temperature;
double LLGMagnet::timeStep;
double LLGMagnet::v [3];
double LLGMagnet::dt;
double LLGMagnet::bulk_sha;
double LLGMagnet::l_shm;
double LLGMagnet::th_shm;
bool LLGMagnet::initialized = false;
bool LLGMagnet::rk4Method = false;

//This method splits a string into a vector of strings given a separator character
//This method exists because c++ string class has a lot of issues
vector<string> LLGMagnet::splitString(string str, char separator){
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

//Constructor
LLGMagnet::LLGMagnet(string id, FileReader * fReader){
	//If some magnet have already initialized the basic constants, skip this step
	if(!LLGMagnet::initialized){
		this->alpha = stod(fReader->getProperty(CIRCUIT, "alpha"));
		this->Ms = stod(fReader->getProperty(CIRCUIT, "Ms"));
		this->temperature = stod(fReader->getProperty(CIRCUIT, "temperature"));
		this->timeStep = stod(fReader->getProperty(CIRCUIT, "timeStep"))*pow(10.0, -9.0);
		this->bulk_sha = stod(fReader->getProperty(CIRCUIT, "spinAngle"));
		this->l_shm = stod(fReader->getProperty(CIRCUIT, "spinDifusionLenght"));
		this->th_shm = stod(fReader->getProperty(CIRCUIT, "heavyMaterialThickness"));
		LLGMagnet::rk4Method = (fReader->getProperty(CIRCUIT, "method") == "RK4");
		//If the method is the RK4, the temperature MUST be 0 K
		if(LLGMagnet::rk4Method)
			this->temperature = 0;
		//Mark as initialized
		LLGMagnet::initialized = true;
	}

	this->id = id;
	string compName = fReader->getItemProperty(DESIGN, id, "component");

	//Initial magnetization
	vector<string> parts;
	parts = splitString(fReader->getItemProperty(DESIGN, id, "magnetization"), ',');
	for(int i=0; i<3; i++){
		this->magnetization[i] = stod(parts[i]);
		this->initialMagnetization[i] = this->magnetization[i];
	}

	//Fixed magnetization
	this->fixedMagnetization = (fReader->getItemProperty(DESIGN, id, "fixedMagnetization") == "true");

	//Geometry
	double width, height, thickness, topCut, bottomCut;
	width = stod(fReader->getItemProperty(COMPONENTS, compName, "width"));
	height = stod(fReader->getItemProperty(COMPONENTS, compName, "height"));
	thickness = stod(fReader->getItemProperty(COMPONENTS, compName, "thickness"));
	topCut = stod(fReader->getItemProperty(COMPONENTS, compName, "topCut"));
	bottomCut = stod(fReader->getItemProperty(COMPONENTS, compName, "bottomCut"));
	this->magnetizationCalculator = new LLGMagnetMagnetization(width, height, thickness, topCut, bottomCut);

	//Position
	parts = splitString(fReader->getItemProperty(DESIGN, id, "position"), ',');
	this->xPosition = stod(parts[0]);
	this->yPosition = stod(parts[1]);

	//Calculate the demag energy
	this->demagTensor = (double **) malloc(3*sizeof(double *));
	this->demagTensor = this->magnetizationCalculator->computeDemag();
	double ** auxND = this->magnetizationCalculator->computeDemag();
	for(int i=0; i<3; i++){
		for(int j=0; j<3; j++){
			nd[i][j] = auxND[i][j];
		}
	}

	this->volume = this->magnetizationCalculator->getVolume();
	
	//Initialize some constants
	initializeConstants();

	//Compute theta_she
	this->theta_she = bulk_sha*(1-(1/cosh(th_shm/l_shm)));
}

void LLGMagnet::initializeConstants(){
	this->alpha_l = 1.0/(1+pow(this->alpha, 2.0));
	this->dt = this->timeStep*gammamu0*this->Ms;
	for(int i=0; i<3; i++){
		this->v[i] = sqrt((2.0*this->alpha*kb*this->temperature) / (mu0*this->Ms*this->Ms*(this->volume * pow(10.0, -27.0))));
	}
}

void LLGMagnet::crossProduct(double *vect_A, double *vect_B, double *cross_P){
    cross_P[0] = vect_A[1] * vect_B[2] - vect_A[2] * vect_B[1];
    cross_P[1] = vect_A[2] * vect_B[0] - vect_A[0] * vect_B[2];
    cross_P[2] = vect_A[0] * vect_B[1] - vect_A[1] * vect_B[0];
}
 
//Compute the magnetization for the next time step
void LLGMagnet::calculateMagnetization(ClockPhase * phase){
	if(isMimicing)
		return;

	double hd[3], hc[3] = {0.0,0.0,0.0}, heff[3];	//Demag, dipolar and effective fields
	double a[3], b[3];	//a and b terms
	double i_s[3];	//spin hall effect
	double u[3], u_plus[3], u_minus[3], a_u[3], b_uplus[3], b_uminus[3];

	//Compute demag field
	for(int i=0; i<3; i++){
		hd[i] = 
			(this->magnetization[0]*nd[0][i] + 
			this->magnetization[1]*nd[1][i] + 
			this->magnetization[2]*nd[2][i])*-1.0;	
	}

	//For each neighbor, compute the dipolar field
	for(int j=0; j<this->neighbors.size(); j++){
		for(int i=0; i<3; i++){
			hc[i] += 
				(neighbors[j]->getMagnet()->getMagnetization()[0]*(this->neighbors[j]->getWeight()[i]) + 
				neighbors[j]->getMagnet()->getMagnetization()[1]*(this->neighbors[j]->getWeight()[i+3]) + 
				neighbors[j]->getMagnet()->getMagnetization()[2]*(this->neighbors[j]->getWeight()[i+6]))*-1.0;
		}
	}

	//Check for the method
	if(LLGMagnet::rk4Method){
		double k1[3], k2[3], k3[3], k4[3], auxSig[3], auxVar[3], auxMag[3], i_s[3], half_is[3], next_is[3];	//Auxiliar variables
		
		for(int i=0; i<3; i++){
			if(this->fixedMagnetization){
				//If the magnetization is fixed, force all external field sorces to be 0
				auxSig[i] = 0;
				i_s[i] = 0;
				half_is[i] = 0;
				next_is[i] = 0;
				auxVar[i] = 0;
			} else{
				//Otherwise, split the external signal into Zeeman field and spin hall field
				auxVar[i] = phase->getVariation()[i];	//The variation of the phase
				auxSig[i] = phase->getSignal()[i];	//The signal value
				i_s[i] = ((-1)*hbar*this->theta_she*(phase->getSignal()[i+3]*pow(10,12)))/(2*q*this->getThickness()*pow(10,(-9))*Ms);
				half_is[i] = ((-1)*hbar*this->theta_she*((phase->getSignal()[i+3] + auxVar[i]/2)*pow(10,12)))/(2*q*this->getThickness()*pow(10,(-9))*Ms);
				next_is[i] = ((-1)*hbar*this->theta_she*((phase->getSignal()[i+3] + auxVar[i])*pow(10,12)))/(2*q*this->getThickness()*pow(10,(-9))*Ms);
			}
		}

		//Compute f term for current time and save in k1
		f_term(this->magnetization, auxSig, hd, hc, i_s, k1);
		//Normalize k1
		for(int i=0; i<3; i++)
			k1[i] *= this->dt;
		
		//Update the signal to the time in between the current and the next
		for(int i=0; i<3; i++)
			auxSig[i] += auxVar[i]/2;

		//Update the auxiliar magnetization to be in between the current and the next time
		for(int i=0; i<3; i++){
			auxMag[i] = this->magnetization[i] + k1[i]/2;
		}

		//Compute f term for the time in between the current and the next and save in k2
		f_term(auxMag, auxSig, hd, hc, half_is, k2);
		//Normalize k2
		for(int i=0; i<3; i++)
			k2[i] *= this->dt;
		
		//Update temporary magnetization
		for(int i=0; i<3; i++)
			auxMag[i] = this->magnetization[i] + k2[i]/2;

		//Compute f term for the new updated magnetization and save in k3
		f_term(auxMag, auxSig, hd, hc, half_is, k3);
		//Normalize k3
		for(int i=0; i<3; i++)
			k3[i] *= this->dt;
		
		//update the signal to be in the next time step
		for(int i=0; i<3; i++)
			auxSig[i] += auxVar[i]/2;
		
		//Update the magnetization using k3
		for(int i=0; i<3; i++)
			auxMag[i] = this->magnetization[i] + k3[i];
		
		//Compute f term for the magnetization in the next time step and save in k4
		f_term(this->magnetization, auxSig, hd, hc, next_is, k4);
		//Normalize k4
		for(int i=0; i<3; i++)
			k4[i] *= this->dt;

		//Compute the magnetization in the next step of time using the f terms
		for(int i=0; i<3; i++){
			this->newMagnetization[i] = this->magnetization[i] + (k1[i] + 2*k2[i] + 2*k3[i] + k4[i])/6;
		}
	} else{
		//RKW2 method
		for(int i=0; i<3; i++){
			if(this->fixedMagnetization)
				//If magnetization is fixed, effective field ignores external sources
				heff[i] = hd[i] + hc[i];
			else{
				//If not, use the signal to compute effective field
				heff[i] = phase->getSignal()[i] / (mu0 * 1000.0 * this->Ms) + hd[i] + hc[i];
			}
		}

		//Make a uniform distribution for the thermal noise
		default_random_engine generator(chrono::system_clock::now().time_since_epoch().count());
		normal_distribution<double> distribution (0.0,1.0);
		this->dW[0] = distribution(generator)*sqrt(this->dt);
		this->dW[1] = distribution(generator)*sqrt(this->dt);
		this->dW[2] = distribution(generator)*sqrt(this->dt);

		for(int i=0; i<3; i++){
			//Ignores the spin hall effect if magnetization is fixed and compute it otherwise
			if(this->fixedMagnetization)
				i_s[i] = 0;
			else
				i_s[i] = ((-1)*hbar*this->theta_she*(phase->getSignal()[i+3]*pow(10,12)))/(2*q*this->getThickness()*pow(10,(-9))*Ms);
		}

		//Compute a and b terms
		a_term(a, heff, i_s, this->magnetization);
		b_term(b, this->magnetization);

		//Compute u term
		for(int i=0; i<3; i++)
			u[i] = this->magnetization[i] + a[i]*dt + b[i]*this->dW[i];

		//Compute u plus term
		for(int i=0; i<3; i++)
			u_plus[i] = this->magnetization[i] + a[i]*dt + b[i]*sqrt(dt);

		//Compute u minus term
		for(int i=0; i<3; i++)
			u_minus[i] = this->magnetization[i] + a[i]*dt - b[i]*sqrt(dt);

		//Recompute a and b terms
		a_term(a_u, heff, i_s, u);
		b_term(b_uplus, u_plus);
		b_term(b_uminus, u_minus);

		//Compute the magnetization in the next step of time
		for(int i=0; i<3; i++){
			this->newMagnetization[i] = this->magnetization[i] + 0.5*(a_u[i] + a[i])*dt + 
										0.25*(b_uplus[i] + b_uminus[i] + 2*b[i])*this->dW[i] +
										0.25*(b_uplus[i] - b_uminus[i]) * (this->dW[i]*this->dW[i] - dt)/sqrt(dt);
		}
	}
}

//Some dark magics to compute f term, used in the RK4 method
void LLGMagnet::f_term(double * currMag, double * currSignal, double* hd, double* hc, double* i_s, double * result){
	double heff[3], m_heff[3], mm_heff[3];
	double m_v[3], mm_v[3], b[3];
	double m_is[3], mm_is[3];

	for(int i=0; i<3; i++){
		if(this->fixedMagnetization)
			heff[i] = hd[i] + hc[i];
		else{
			heff[i] = currSignal[i] / (mu0 * 1000.0 * this->Ms) + hd[i] + hc[i];
		}
	}

	crossProduct(currMag, i_s, m_is);
	crossProduct(currMag, m_is, mm_is);

	crossProduct(currMag, heff, m_heff);
	crossProduct(currMag, m_heff, mm_heff);

	for(int i=0; i<3; i++){
		result[i] = -1.0*this->alpha_l*(
			m_heff[i] + this->alpha*mm_heff[i] - mm_is[i]
			);
	}
}

//Some dark magics to compute a term, used in the RKW2 method
void LLGMagnet::a_term(double* a, double* h_eff, double* i_s, double* m){
	double m_is[3], mm_is[3], m_heff[3], mm_heff[3];

	crossProduct(m, i_s, m_is);
	crossProduct(m, m_is, mm_is);

	crossProduct(m, h_eff, m_heff);
	crossProduct(m, m_heff, mm_heff);

	for(int i=0; i<3; i++){
		a[i] = -1.0*this->alpha_l*(
			m_heff[i] + this->alpha*mm_heff[i] - mm_is[i]
			) + (
			alpha_l * pow(v[i], 2.0) * m[i]
			);
	}
}

//Some dark magics to compute b term, used in the RKW2 method
void LLGMagnet::b_term(double* b, double* m){
	double m_v[3], mm_v[3];

	crossProduct(m, v, m_v);
	crossProduct(m, m_v, mm_v);

	for(int i=0; i<3; i++){
		b[i] = -1.0*this->alpha_l*(
			m_v[i]+this->alpha*mm_v[i]
			);
	}
}

double * LLGMagnet::getMagnetization(){
	return this->magnetization;
}

void LLGMagnet::setMimic(Magnet * mimic){
	if(mimic == NULL)
		return;
	this->mimic = mimic;
	this->isMimicing = true;
}

void LLGMagnet::updateMagnetization(){
	if(isMimicing){
		this->mimic->updateMagnetization();
		this->magnetization[0] = this->mimic->getMagnetization()[0];
		this->magnetization[1] = this->mimic->getMagnetization()[1];
		this->magnetization[2] = this->mimic->getMagnetization()[2];
		return;
	}
	//Normalize and update the magnetization value
	double module = sqrt(pow(this->newMagnetization[0], 2.0) + pow(this->newMagnetization[1], 2.0) + pow(this->newMagnetization[2], 2.0));
	this->magnetization[0] = this->newMagnetization[0]/module;
	this->magnetization[1] = this->newMagnetization[1]/module;
	this->magnetization[2] = this->newMagnetization[2]/module;
}

void LLGMagnet::addNeighbor(Magnet * neighbor, double * ratio){
	//Check if the magnet is a neighbor and add it if so
	if(this->isNeighbor(static_cast<LLGMagnet *> (neighbor), *ratio)){
		//Distance between magnets
		double vDist = (this->yPosition - (static_cast<LLGMagnet *> (neighbor))->getYPosition());
		double hDist = (this->xPosition - (static_cast<LLGMagnet *> (neighbor))->getXPosition());
		//Neighbor px, py and t
		double * npx = (static_cast<LLGMagnet *> (neighbor))->getPx();
		double * npy = (static_cast<LLGMagnet *> (neighbor))->getPy();
		double nt = (static_cast<LLGMagnet *> (neighbor))->getThickness();
		//Dipolar tensor
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

void LLGMagnet::resetMagnetization(){
	this->magnetization[0] = initialMagnetization[0];
	this->magnetization[1] = initialMagnetization[1];
	this->magnetization[2] = initialMagnetization[2];
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
	//The other magnet px and py
	double * mpx = magnet->getPx();
	double * mpy = magnet->getPy();
	//X and Y deltas
	double xDiff, yDiff;
	xDiff = abs(this->xPosition - magnet->getXPosition()) - (mpx[1]-mpx[0]) - (getPx()[1] - getPx()[0]);
	yDiff = abs(this->yPosition - magnet->getYPosition()) - (mpy[0]-mpy[3]) - (getPy()[0] - getPy()[3]);
	//Compute the distance
	double dist = sqrt(pow(xDiff, 2.0) + pow(yDiff, 2.0));
	//Compare to the RADIUS (misspelled here)
	return dist < ratio;
}

void LLGMagnet::makeHeader(ofstream * out){
	*(out) << this->id << "_x,"
		<< this->id << "_y,"
		<< this->id << "_z,";
}

vector <Neighbor *> LLGMagnet::getNeighbors(){
	return this->neighbors;
}