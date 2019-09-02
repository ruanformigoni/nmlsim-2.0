#include "Simulator/Simulation.h"
#include "Others/Includes.h"
#include "sys/types.h"
#include "sys/sysinfo.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include <chrono>


int parseLine(char* line){
    // This assumes that a digit will be found and the line ends in " Kb".
    int i = strlen(line);
    const char* p = line;
    while (*p <'0' || *p > '9') p++;
    line[i-3] = '\0';
    i = atoi(p);
    return i;
}

int getVirtualValue(){ //Note: this value is in KB!
    FILE* file = fopen("/proc/self/status", "r");
    int result = -1;
    char line[128];

    while (fgets(line, 128, file) != NULL){
        if (strncmp(line, "VmSize:", 7) == 0){
            result = parseLine(line);
            break;
        }
    }
    fclose(file);
    return result;
}

int getPhysicalValue(){ //Note: this value is in KB!
    FILE* file = fopen("/proc/self/status", "r");
    int result = -1;
    char line[128];

    while (fgets(line, 128, file) != NULL){
        if (strncmp(line, "VmRSS:", 6) == 0){
            result = parseLine(line);
            break;
        }
    }
    fclose(file);
    return result;
}

int main(int argc, char const *argv[]) {
	Simulation * simulation;
    // Simulation::demagLog.open("Files/DemagTensors.log", ios::app);
    Simulation::dipBib.clear();
	Simulation::demagBib.clear();
	Simulation::volumeBib.clear();

    auto begin = chrono::high_resolution_clock::now();    
    Simulation::verifyTensorsMap();
    auto end = chrono::high_resolution_clock::now();    
    auto dur = end - begin;
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(dur).count();
    cout << "Tensors loading time: " << ms << endl;
    
    if(string(argv[2]) == "SingleFileMode")
        simulation = new Simulation(argv[1]);
    else
        // cout << "Vai simular com 2 argumentos!" << endl;
    	simulation = new Simulation(argv[1], argv[2]);
    

	simulation->simulate();

    // Simulation::demagLog.close();
	cout << "Memory Used: " << getPhysicalValue() + getVirtualValue() << " KB" << endl;
	return 0;
}