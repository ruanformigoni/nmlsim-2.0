#include "ClockPhase.h"

ClockPhase::ClockPhase(string phaseName, double phaseDuration, double * initialPhaseSignal, double * endPhaseSignal, double * variation, int vLenght){
	this->name = phaseName;
	this->vLenght = vLenght;
	this->duration = phaseDuration;
	this->endPhaseSignal = endPhaseSignal;
	this->variation = variation;
	this->initialSignal = initialPhaseSignal;
}

double * ClockPhase::getSignal(int numberOfSteps){
	//DANGER! This method allocs memory and c++ does not have garbage collector. Therefore, coders MUST free the signal vector after using it
	double * currentSignal = (double*)malloc(vLenght*sizeof(double));
	for(int i=0; i<vLenght; i++){
		//Current signal equals initial + variation
		currentSignal[i] = this->initialSignal[i]+this->variation[i]*numberOfSteps;
		//Check superior and inferior boundries
		if((currentSignal[i] > this->endPhaseSignal[i] && variation[i] > 0) || (currentSignal[i] < this->endPhaseSignal[i] && variation[i] < 0))
			currentSignal[i] = endPhaseSignal[i];
	}
	return currentSignal;
}

double ClockPhase::getPhaseDuration(){
	return this->duration;
}

double * ClockPhase::getVariation(){
	return this->variation;
}

string ClockPhase::getPhaseName(){
	return this->name;
}