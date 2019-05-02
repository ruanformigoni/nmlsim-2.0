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
	THIAGO,
	LLG
};

enum simulationExecution{
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