#include "../Others/Includes.h"

#ifndef CLOCKPHASE_H
#define CLOCKPHASE_H

//Class that encapsulates a clock phase
class ClockPhase{
private:
	string name;	//ID
	double myTimer;	//Timer to check when it ends
	double duration;	//Duration
	int vLenght;	//Lenght of the signal vector
	//Signal vectors
	double * currentSignal;
	double * initialSignal;
	double * endPhaseSignal;
	double * variation;	//Variation

public:
	//Constructor
	ClockPhase(string phaseName, double phaseDuration, double * initialPhaseSignal, double * endPhaseSignal, double * variation, int vLenght);
	//Returns the current signal
	double * getSignal();
	//Returns the variation
	double * getVariation();
	//Updates the time and signal with a new step
	void nextTimeStep(double deltaTime);
	//Returns the ID
	string getPhaseName();
	//Returns the duration
	double getPhaseDuration();
	//Print values in the file
	void dumpValues(ofstream * out);
	//Reset timer and signal value
	void restartPhase();
};

#endif