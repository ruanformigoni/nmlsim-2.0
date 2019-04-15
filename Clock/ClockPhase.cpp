#include "ClockPhase.h"

ClockPhase::ClockPhase(string phaseName, double phaseDuration, double * initialPhaseSignal, double * endPhaseSignal, double * variation, int vLenght){
	this->name = phaseName;
	this->vLenght = vLenght;
	this->duration = phaseDuration;
	this->endPhaseSignal = endPhaseSignal;
	this->variation = variation;
	this->initialSignal = initialPhaseSignal;
	this->currentSignal = (double*)malloc(vLenght*sizeof(double));
	this->myTimer = 0.0;
	for(int i=0; i<vLenght; i++){
		this->currentSignal[i] = initialSignal[i];
	}
}

double * ClockPhase::getSignal(){
	return this->currentSignal;
}

void ClockPhase::restartPhase(){
	this->myTimer = 0.0;
	for(int i=0; i<vLenght; i++){
		this->currentSignal[i] = this->initialSignal[i];
	}
}

void ClockPhase::nextTimeStep(double deltaTime){
	this->myTimer += deltaTime;
	if(myTimer > duration){
		restartPhase();
	}
	else{
		for(int i=0; i<vLenght; i++){
			this->currentSignal[i] += this->variation[i];
			if(this->variation[i] > 0 && this->currentSignal[i] > endPhaseSignal[i])
				this->currentSignal[i] = endPhaseSignal[i];
			if(this->variation[i] < 0 && this->currentSignal[i] < endPhaseSignal[i])
				this->currentSignal[i] = endPhaseSignal[i];
		}
	}
}

double ClockPhase::getPhaseDuration(){
	return this->duration;
}

void ClockPhase::dumpValues(ofstream * out){
	for(int i=0; i<vLenght; i++){
		(*out) << this->currentSignal[i] << ",";
	}
}

double * ClockPhase::getVariation(){
	return this->variation;
}

string ClockPhase::getPhaseName(){
	return this->name;
}