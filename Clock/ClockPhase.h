#include "../Others/Includes.h"

#ifndef CLOCKPHASE_H
#define CLOCKPHASE_H

//Class that encapsulates a clock phase
class ClockPhase{
private:
	string name;	//ID
	double duration;	//Duration
	int vLenght;	//Lenght of the signal vector
	double * initialSignal;
	double * endPhaseSignal;
	double * variation;	//Variation

public:
	//Constructor
	ClockPhase(string phaseName, double phaseDuration, double * initialPhaseSignal, double * endPhaseSignal, double * variation, int vLenght);
	//Returns the current signal
	double * getSignal(int numberOfSteps);
	//Returns the variation
	double * getVariation();
	//Returns the ID
	string getPhaseName();
	//Returns the duration
	double getPhaseDuration();
};

#endif