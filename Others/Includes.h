#ifndef INCLUDES_H
#define INCLUDES_H

#include <vector>
#include <string>
#include <stdlib.h>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <tgmath.h>

using namespace std;

enum magnetType{
	INPUT,
	OUTPUT,
	REGULAR,
	CROSS
};

enum simulationType{
	INVALIDTYPE,
	THIAGO,
	LLG
};

enum simulationExecution{
	INVALIDSIMULATION,
	DIRECT,
	EXAUSTIVE,
	VERBOSE,
	REPETITIVE
};

enum propertyType{
	CIRCUIT,
	PHASE,
	ZONE,
	COMPONENTS,
	DESIGN
};

#endif