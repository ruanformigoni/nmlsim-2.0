#include "../Others/Includes.h"

#ifndef FILEREADER_H
#define FILEREADER_H

//Class that reads and parses and XML file
class FileReader {
private:
	string filePath;	//File path
	string content;	//Content of the file
	string circuitTag;	//Content in the circuit tag
	string phaseTag;	//Content in the phase tag
	string zoneTag;	//Content in the zone tag
	string componentsTag;	//Content in the components tag
	string designTag;	//Content in the design tag

	//Method to remove comments <!-- -->
	void removeComments();
	//Method to split the content into the tags
	void splitTags();

public:
	//Constructor
	FileReader(string filePath);
	//Return the engine type (LLG or Behaviour)
	simulationType getEngine ();
	//Return the simulation mode
	simulationExecution getSimMode ();
	//Return a property from a tag
	string getProperty(propertyType pType, string propertyName);
	//Return a item from a tag
	vector<string> getItems(propertyType pType);
	//Return a property from an item
	string getItemProperty(propertyType pType, string itemName, string propertyName);
	//Return all properties from an item
	vector <string> getAllItemProperties(propertyType pType, string itemName);
};

#endif