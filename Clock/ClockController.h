#include "../Others/Includes.h"
#include "ClockZone.h"
#include "ClockPhase.h"

#ifndef CLOCKCONTROLLER_H
#define CLOCKCONTROLLER_H

class ClockController{
private:
	vector <ClockZone *> zones;
	vector <ClockPhase *> phases;
	double deltaTime;

public:
	ClockController(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime);
	void nextTimeStep();
	void addMagnetToZone(Magnet * magnet, int zoneIndex);
	void dumpZonesValues(ofstream * outFile);
	void dumpMagnetsValues(ofstream * outFile);
	ClockZone* getClockZone(int zoneId);
	vector <Magnet *> getMagnetsFromAllZones();
	void restartAllPhases();
};

#endif