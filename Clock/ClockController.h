#include "../Others/Includes.h"
#include "ClockZone.h"
#include "ClockPhase.h"
#include "../Magnet/Magnet.h"

#ifndef CLOCKCONTROLLER_H
#define CLOCKCONTROLLER_H

//Class that encapsulates the clock controller
class ClockController{
private:
	vector <ClockZone *> zones;	//All zones
	vector <ClockPhase *> phases;	//All phases
	double deltaTime;	//time step

public:
	//Constructor
	ClockController(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime);
	//Update the system by one step of time
	void nextTimeStep();
	//Add a magnet to a clock zone
	void addMagnetToZone(Magnet * magnet, int zoneIndex);
	//Dump all magnets values in the file
	void dumpMagnetsValues(ofstream * outFile);
	//Return the clock zone by the ID
	ClockZone* getClockZone(int zoneId);
	//Return all magnets
	vector <Magnet *> getMagnetsFromAllZones();
	//Reset the zone's phase to the initial one
	void resetZonesPhases();
	//Write the header in the file
	void makeHeader(ofstream * outFile);
};

#endif