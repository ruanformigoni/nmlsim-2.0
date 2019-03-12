#include "ClockPhase.h"

ClockPhase::ClockPhase(string phaseName, double phaseDuration, double * endPhaseSignal, double * variation){
	this->name = phaseName;
	this->duration = phaseDuration;
	this->endPhaseSignal[0] = endPhaseSignal[0];
	this->endPhaseSignal[1] = endPhaseSignal[1];
	this->endPhaseSignal[2] = endPhaseSignal[2];
	this->variation[0] = variation[0];
	this->variation[1] = variation[1];
	this->variation[2] = variation[2];
}

double * ClockPhase::getSignal(){
	return this->currentSignal;
}

void ClockPhase::setInitialSignal(double * signal){
	this->initialSignal[0] = signal[0];
	this->initialSignal[1] = signal[1];
	this->initialSignal[2] = signal[2];
	restartPhase();
}

void ClockPhase::restartPhase(){
	this->myTimer = 0.0;
	this->currentSignal[0] = this->initialSignal[0];
	this->currentSignal[1] = this->initialSignal[1];
	this->currentSignal[2] = this->initialSignal[2];
}

void ClockPhase::nextTimeStep(double deltaTime){
	this->myTimer += deltaTime;
	if(myTimer >= duration){
		restartPhase();
	}
	else{
		for(int i=0; i<3; i++){
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

void ClockPhase::dumpValues(ofstream * outFile){
	*(outFile) << "duration: " << this->duration << " ";
	*(outFile) << "name: " << this->name << endl;
	for (int i=0; i<3; i++){
		*(outFile) << "component " << ((i==0)?"x":((i==1)?"y":"z")) << " ";
		*(outFile) << "currSig: " << this->currentSignal[i] << " ";
		*(outFile) << "endSig: " << this->endPhaseSignal[i] << " ";
		*(outFile) << "variation: " << this->variation[i] << endl;
	}
}

double * ClockPhase::getVariation(){
	return this->variation;
}

string ClockPhase::getPhaseName(){
	return this->name;
}