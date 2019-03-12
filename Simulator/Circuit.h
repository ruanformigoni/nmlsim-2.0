#include "../Others/Includes.h"
#include "../Magnet/Magnet.h"
#include "../Clock/ClockController.h"
#include "../Clock/ClockZone.h"
#include "../Clock/ClockPhase.h"

#ifndef CIRCUIT_H
#define CIRCUIT_H

class Circuit{
private:
	ClockController * clockCtrl;
	vector <Magnet*> inputMagnets;
	vector <Magnet*> outputMagnets;

public:
	Circuit(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime);
	Circuit(vector <Magnet*> input, vector <Magnet*> output, vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime);
	void addMagnetToZone(Magnet * magnet, int zoneID);
	void addInputMagnet(Magnet * magnet);
	void addOutputMagnet(Magnet * magnet);
	void nextTimeStep();
	Magnet* getMagnet(string inOrOut, string id);
	Magnet* getMagnet(int zoneId, string id);
	void dumpZonesValues(ofstream * outFile);
	void dumpMagnetsValues(ofstream * outFile);
	void setInputs(int mask);
	int getInputsSize();
	void dumpInOutValues(ofstream * outFile);
	vector <Magnet *> getAllMagnets();
};

#endif