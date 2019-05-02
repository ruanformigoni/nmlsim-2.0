#include "../Others/Includes.h"
#include "Circuit.h"
#include "../Clock/ClockController.h"
#include "../Clock/ClockZone.h"
#include "../Clock/ClockPhase.h"
#include "../Magnet/Magnet.h"
#include "../Magnet/ThiagoMagnet.h"
#include "../Magnet/LLGMagnet.h"
#include "FileReader.h"

#ifndef SIMULATION_H
#define SIMULATION_H

class Simulation{
private:
	double currentTime;
	double deltaTime;
	double simulationDuration;

	Circuit* circuit;
	simulationType mySimType;
	simulationExecution mySimMode;

	FileReader* fReader;
	ofstream outFile;

	void buildClkCtrl();
	void buildCircuit();
	void buildMagnets();
	void buildNeighbors();
	void verboseSimulation(double reportDeltaTime);
	void exaustiveSimulation();
	void directSimulation();
	void repetitiveSimulation();
	vector<string> splitString(string str, char separator);

public:
	Simulation(string filePath, string outFilePath);
	Simulation(string singlePath);
	string getFileName(string initial);
	void simulate();

};

#endif