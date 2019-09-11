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

//Class that encapsulates the simulation
class Simulation{
private:
	double currentTime;	//Current time
	double deltaTime;	//Time variation
	double simulationDuration;	//Simulation duration

	Circuit* circuit;	//The circuit
	simulationType mySimType;	//Simulation engine
	simulationExecution mySimMode;	//Simulation mode

	FileReader* fReader;	//File reader
	ofstream outFile;	//Output file

	//Method to build the clock controller
	void buildClkCtrl();
	//Method to build the circuit
	void buildCircuit();
	//Method to build the magnets
	void buildMagnets();
	//Method to add magnets as neighbors
	void buildNeighbors();
	//Perform the verbose simulation
	void verboseSimulation(double reportDeltaTime);
	//Perform the exaustive simulation
	void exaustiveSimulation();
	//Perform the direct simulation
	void directSimulation();
	//Perform the repetitive simulation
	void repetitiveSimulation();
	//Method to split a string in parts
	vector<string> splitString(string str, char separator);

public:
	static ofstream demagLog;	//Demag log
	static map<string, double *> dipBib;	//Dipolar library
	static map<string, double **> demagBib;	//Demag library
	static map<string, double> volumeBib;	//Volume library

	//Contructor with two file path
	Simulation(string filePath, string outFilePath);
	//Contructor with one file path
	Simulation(string singlePath);
	//Return the file name
	string getFileName(string initial);
	//Simulate the circuit
	void simulate();
	//Load the log
	static void verifyTensorsMap(string logPath);
};

#endif