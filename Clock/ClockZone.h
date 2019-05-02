#include "../Others/Includes.h"
#include "../Magnet/Magnet.h"
#include "ClockPhase.h"

#ifndef CLOCKZONE_H
#define CLOCKZONE_H

class ClockZone{
private:
	vector <Magnet *> magnets;
	ClockPhase * myPhase;
	vector <string> myPhases;
	double timeInPhase;

public:
	ClockZone(ClockPhase * phase, vector <string> phases);
	string getZonePhase();
	double * getZoneSignal();
	void addMagnet(Magnet * magnet);
	void updateMagnets();
	double getTimeInPhase();
	void updateTimeInPhase(double variation);
	void resetTimeInPhase();
	bool isPhaseEnded();
	void makeHeader(ofstream * outFile);
	void updatePhase(ClockPhase * newPhase);
	void dumpMagnetsValues(ofstream * outFile);
	vector<string> getPhases();
	Magnet * getMagnet(string magnetId);
	vector <Magnet *> getAllMagnets();
	void dumpPhaseValues(ofstream * outFile);
};

#endif