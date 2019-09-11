#include "Simulator/Simulation.h"
#include "Others/Includes.h"
#include "sys/types.h"
#include "sys/sysinfo.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include <chrono>

//Parse a line into a value
int parseLine(char *line){
	// This assumes that a digit will be found and the line ends in " Kb".
	int i = strlen(line);
	//Poniter to the line
	const char *p = line;
	//Find the first digit
	while (*p < '0' || *p > '9')
		p++;
	//Removes the KB in the end
	line[i - 3] = '\0';
	//Parse
	i = atoi(p);
	return i;
}

//Return the memory used as virtual. Note: this value is in KB!
int getVirtualValue(){
	FILE *file = fopen("/proc/self/status", "r");
	int result = -1;
	char line[128];

	while (fgets(line, 128, file) != NULL){
		//Search the Virtual Memory Size
		if (strncmp(line, "VmSize:", 7) == 0){
			//Parse the line and end the loop
			result = parseLine(line);
			break;
		}
	}
	fclose(file);
	return result;
}

//Return the memory used as physical. Note: this value is in KB!
int getPhysicalValue(){
	FILE *file = fopen("/proc/self/status", "r");
	int result = -1;
	char line[128];

	while (fgets(line, 128, file) != NULL){
		//Search the Physical Memory Size
		if (strncmp(line, "VmRSS:", 6) == 0){
			//Parse the line and end the loop
			result = parseLine(line);
			break;
		}
	}
	fclose(file);
	return result;
}

int main(int argc, char const *argv[]){
	//Get the time when the program starts
	auto begin = chrono::high_resolution_clock::now();
	
	Simulation *simulation;

	//Clear all libraries
	Simulation::dipBib.clear();
	Simulation::demagBib.clear();
	Simulation::volumeBib.clear();
	
	//Finds the log file and load it
	string logPath = argv[2];
	logPath = logPath.substr(0, logPath.length() - 4);
	logPath += ".log";
	Simulation::verifyTensorsMap(logPath);
	
	//Compute the time to load the log file
	auto end = chrono::high_resolution_clock::now();
	auto dur = end - begin;
	auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(dur).count();	
	cout << "Demag tensors loading time: " << ms << " milliseconds" << endl;

	//Check if there is an output file name or if it is a single file mode
	if (string(argv[2]) == "SingleFileMode")
		simulation = new Simulation(argv[1]);
	else
		simulation = new Simulation(argv[1], argv[2]);

	//Initiate the simulation
	simulation->simulate();

	//Close the log file
	Simulation::demagLog.close();

	//Compute the simulation time and memry usage
	auto simEnd = chrono::high_resolution_clock::now();
	auto simDur = simEnd - begin;
	auto simMs = chrono::duration_cast<chrono::milliseconds>(simDur).count();
	cout << "All done!\nMemory Used: " << getPhysicalValue() + getVirtualValue() << " KB" << endl << "Simulation time: " << simMs << " milliseconds" << endl;

	return 0;
}