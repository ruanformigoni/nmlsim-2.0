#include "../Others/Includes.h"
// #include "../Magnet/Magnet.h"
#include "ClockPhase.h"

#ifndef CLOCKZONE_H
#define CLOCKZONE_H

class Magnet;

//Class that encapsulates the clock zone
class ClockZone{
private:
	vector <Magnet *> magnets;	//List of magnets in that clock zone
	ClockPhase * myPhase;	//Current phase of the zone
	vector <string> myPhases;	//List of phases
	int stepsInPhase;	//Steps of time in a phase

public:
	//Constructor
	ClockZone(ClockPhase * phase, vector <string> phases);
	//Returns the current phase
	string getZonePhase();
	//Returns the current signal
	double * getSignal();
	//Returns the zone variation
	double * getZoneSignalVariation();
	//Add a magnet to the clock zone
	void addMagnet(Magnet * magnet);
	//Returns the time in the current phase
	int getStepsInPhase();
	//Updates the time in the phase
	void incrementStepsInPhase();
	//Resets the timer
	void resetStepsInPhase();
	//Checks if the phase has ended
	bool isPhaseEnded(double timeStep);
	//Updates the phase
	void updatePhase(ClockPhase * newPhase);
	//Returns the list of phases
	vector<string> getPhases();
	//Returns all magnets
	vector <Magnet *> getAllMagnets();
};

#endif