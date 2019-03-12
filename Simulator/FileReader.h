#include "../Others/Includes.h"

#ifndef FILEREADER_H
#define FILEREADER_H

class FileReader {
private:
	string filePath;
	string content;
	string circuitTag;
	string phaseTag;
	string zoneTag;
	string componentsTag;
	string designTag;

	void removeComments();
	void splitTags();

public:
	FileReader(string filePath);
	simulationType getEngine ();
	simulationExecution getSimMode ();
	string getProperty(propertyType pType, string propertyName);
	vector<string> getItems(propertyType pType);
	string getItemProperty(propertyType pType, string itemName, string propertyName);
	vector <string> getAllItemProperties(propertyType pType, string itemName);
};

#endif