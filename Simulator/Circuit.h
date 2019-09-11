#include "../Others/Includes.h"
#include "../Magnet/Magnet.h"
#include "../Clock/ClockController.h"
#include "../Clock/ClockZone.h"
#include "../Clock/ClockPhase.h"

#ifndef CIRCUIT_H
#define CIRCUIT_H

//Class that encapsulates the circuit
class Circuit{
private:
	ClockController * clockCtrl;	//Clock controller
	vector <Magnet*> inputMagnets;	//Input magnets list
	vector <Magnet*> outputMagnets;	//Output magnets list

public:
	//Constructor without the lists of input and output
	Circuit(vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime);
	//Constructor with the lists of input and output
	Circuit(vector <Magnet*> input, vector <Magnet*> output, vector <ClockZone *> zones, vector <ClockPhase *> phases, double deltaTime);
	//Add a magnet to a zone by index
	void addMagnetToZone(Magnet * magnet, int zoneID);
	//Add a magnet as an input
	void addInputMagnet(Magnet * magnet);
	//Add a magnet as an output
	void addOutputMagnet(Magnet * magnet);
	//Simulates the next step of time
	void nextTimeStep();
	//Returns a input or output magnet
	Magnet* getMagnet(string inOrOut, string id);
	//Returns a regular magnet
	Magnet* getMagnet(int zoneId, string id);
	//Dump zone values in the file
	void dumpZonesValues(ofstream * outFile);
	//Dump magnets values in the file
	void dumpMagnetsValues(ofstream * outFile);
	//Set the inputs with a bit mask
	void setInputs(int mask, simulationType type);
	//Return the number of inputs
	int getInputsSize();
	//Dump input and output magnets values in the file
	void dumpInOutValues(ofstream * outFile);
	//Return all magnets
	vector <Magnet *> getAllMagnets();
	//Restart all phases
	void restartAllPhases();
	//Restart all zones phase
	void resetZonesPhases();
	//Restart all magnets initial magnetization
	void restartAllMagnets();
	//Write the header of the file
	void makeHeader(ofstream * outFile);
};

#endif