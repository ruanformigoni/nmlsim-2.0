#include "../Others/Includes.h"

#ifndef CLOCKPHASE_H
#define CLOCKPHASE_H

class ClockPhase{
private:
	string name;
	double myTimer;
	double duration;
	double currentSignal[3];
	double initialSignal[3];
	double endPhaseSignal[3];
	double variation[3];

public:
	ClockPhase(string phaseName, double phaseDuration, double * endPhaseSignal, double * variation);
	double * getSignal();
	void setInitialSignal(double * signal);
	double * getVariation();
	void nextTimeStep(double deltaTime);
	string getPhaseName();
	double getPhaseDuration();
	void dumpValues(ofstream * outFile);
	void restartPhase();
};

#endif