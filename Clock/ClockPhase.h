#include "../Others/Includes.h"

#ifndef CLOCKPHASE_H
#define CLOCKPHASE_H

class ClockPhase{
private:
	string name;
	double myTimer;
	double duration;
	int vLenght;
	double * currentSignal;
	double * initialSignal;
	double * endPhaseSignal;
	double * variation;

public:
	ClockPhase(string phaseName, double phaseDuration, double * initialPhaseSignal, double * endPhaseSignal, double * variation, int vLenght);
	double * getSignal();
	double * getVariation();
	void nextTimeStep(double deltaTime);
	string getPhaseName();
	double getPhaseDuration();
	void dumpValues(ofstream * out);
	void restartPhase();
};

#endif