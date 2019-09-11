#include "../Others/Includes.h"
#include "../Magnet/Magnet.h"
#include "ClockPhase.h"

#ifndef CLOCKZONE_H
#define CLOCKZONE_H

//Class that encapsulates the clock zone
class ClockZone{
private:
	vector <Magnet *> magnets;	//List of magnets in that clock zone
	ClockPhase * myPhase;	//Current phase of the zone
	vector <string> myPhases;	//List of phases
	double timeInPhase;	//Time in a phase

public:
	//Constructor
	ClockZone(ClockPhase * phase, vector <string> phases);
	//Returns the current phase
	string getZonePhase();
	//Returns the current signal
	double * getZoneSignal();
	//Add a magnet to the clock zone
	void addMagnet(Magnet * magnet);
	//Update the magnets magnetization
	void updateMagnets();
	//Returns the time in the current phase
	double getTimeInPhase();
	//Updates the time in the phase
	void updateTimeInPhase(double variation);
	//Resets the timer
	void resetTimeInPhase();
	//Checks if the phase has ended
	bool isPhaseEnded();
	//Builds the file header
	void makeHeader(ofstream * outFile);
	//Updates the phase
	void updatePhase(ClockPhase * newPhase);
	//Dump magnet values in the file
	void dumpMagnetsValues(ofstream * outFile);
	//Returns the list of phases
	vector<string> getPhases();
	//Get a magnet from its ID
	Magnet * getMagnet(string magnetId);
	//Returns all magnets
	vector <Magnet *> getAllMagnets();
	//Dump the phase values
	void dumpPhaseValues(ofstream * outFile);
};

#endif