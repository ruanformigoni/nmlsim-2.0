#include "FileReader.h"

FileReader::FileReader(string filePath){
	char aux;
	//Open the file and load in the content string
	ifstream myFile (filePath.c_str());
	while(myFile.get(aux))
		this->content += aux;
	//Remove comments from the content
	removeComments();
	//Split into tags
	splitTags();
	//Close the file
	myFile.close();
}

void FileReader::removeComments(){
	int start, end;	//Start and end of the comment
	start = end = 0;
	//While there is content to seek...
	while(start < this->content.size()){
		//Find the start of a comment, from the last start (initially at 0)
		start = this->content.find("<!--", start);
		//If there is no start, break the loop
		if(start >= this->content.size())
			break;
		//Find the end of the comment, from the start
		end = this->content.find("-->", start);
		//If there is no start, break the loop
		if(start >= this->content.size())
			break;
		//Erase the content
		this->content.erase(start, end-start+3);
	}
}

void FileReader::splitTags(){
	int start, end;	//Start and end of a tag
	//Find the start of the tag circuit
	start = this->content.find("<circuit>", 0);
	//Find the end of the tag circuit
	end = this->content.find("</circuit>", start);
	//Get the content from that tag
	this->circuitTag = this->content.substr(start+10, end-start-10);
	//Erase the content from that tag from the content string
	this->content.erase(start, end-start+10);

	//Similar to the last section, but with clock zone
	start = this->content.find("<clockZone>", 0);
	end = this->content.find("</clockZone>", start);
	this->zoneTag = this->content.substr(start+12, end-start-12);
	this->content.erase(start, end-start+12);
	
	//Similar to the last section, but with clock phase
	start = this->content.find("<clockPhase>", 0);
	end = this->content.find("</clockPhase>", start);
	this->phaseTag = this->content.substr(start+13, end-start-13);
	this->content.erase(start, end-start+13);

	//Similar to the last section, but with components
	start = this->content.find("<components>", 0);
	end = this->content.find("</components>", start);
	this->componentsTag = this->content.substr(start+13, end-start-13);
	this->content.erase(start, end-start+13);

	//Similar to the last section, but with design
	start = this->content.find("<design>", 0);
	end = this->content.find("</design>", start);
	this->designTag = this->content.substr(start+9, end-start-9);
	this->content.erase(start, end-start+9);
}

simulationType FileReader::getEngine (){
	string aux = "";	//Engine string text
	int start, end;	//Start and end of the property engine
	//Find the engine in the circuit tag
	start = this->circuitTag.find("engine=\"", 0);
	end = this->circuitTag.find("\"", start+9);	//Ends with an "
	aux = this->circuitTag.substr(start+8, end-(start+8));	//There ar 8 character in (engine=")

	if(aux == "LLG")
		return LLG;
	if(aux == "Behaviour")
		return THIAGO;
}

simulationExecution FileReader::getSimMode (){
	string aux = "";	//Mode string text
	int start, end;	//Start and end of the property mode
	//Find the mode in the circuit tag, similar to the last method
	start = this->circuitTag.find("simulationMode=\"", 0);
	end = this->circuitTag.find("\"", start+17);
	aux = this->circuitTag.substr(start+16, end-(start+16));

	if(aux == "direct")
		return DIRECT;
	if(aux == "exaustive")
		return EXAUSTIVE;
	if(aux == "verbose")
		return VERBOSE;
	if(aux == "repetitive")
		return REPETITIVE;
}

string FileReader::getProperty(propertyType pType, string propertyName){
	string result, tag;

	//Get the correct tag string 
	switch(pType){
		case CIRCUIT:
			tag = circuitTag;
		break;
		case PHASE:
			tag = phaseTag;
		break;
		case ZONE:
			tag = zoneTag;
		break;
		case COMPONENTS:
			tag = componentsTag;
		break;
		case DESIGN:
			tag = designTag;
		break;
	}

	//Find the property in the tag
	int start, end;
	start = tag.find(propertyName + "=\"", 0);
	end = tag.find("\"", start+propertyName.size()+2);
	result = tag.substr(start+propertyName.size()+2, end-(start+propertyName.size()+2));	//Considers the size of the string of the property and the signal (=")
	
	return result;
}

vector<string> FileReader::getItems(propertyType pType){
	string tag, aux;
	vector<string> result;

	//Get the correct tag string 
	switch(pType){
		case CIRCUIT:
			tag = circuitTag;
		break;
		case PHASE:
			tag = phaseTag;
		break;
		case ZONE:
			tag = zoneTag;
		break;
		case COMPONENTS:
			tag = componentsTag;
		break;
		case DESIGN:
			tag = designTag;
		break;
	}

	//Find the items which start with item name=" and end with "
	int start, end, newStart;
	start = end = newStart = 0;
	while(start < tag.size()){
		start = tag.find("<item name=\"", newStart);
		if(start >= tag.size())
			break;
		end = tag.find ("\"", start+12);
		newStart = tag.find ("</item>", end);
		aux = tag.substr(start+12, end-start-12);
		result.push_back(aux);
	}
	return result;
}

string FileReader::getItemProperty(propertyType pType, string itemName, string propertyName){
	string result, tag;

	//Get the correct tag string 
	switch(pType){
		case CIRCUIT:
			tag = circuitTag;
		break;
		case PHASE:
			tag = phaseTag;
		break;
		case ZONE:
			tag = zoneTag;
		break;
		case COMPONENTS:
			tag = componentsTag;
		break;
		case DESIGN:
			tag = designTag;
		break;
	}

	//Find the items which start with item name=" and end with "
	int start, end, limit;
	start = tag.find("<item name=\"" + itemName + "\"", 0);
	limit = tag.find("</item>", start);
	//Find the property inside the item
	start = tag.find(propertyName + "=\"", start);
	if(start > limit)
		return "";
	end = tag.find("\"", start+propertyName.size()+2);

	result = tag.substr(start+propertyName.size()+2, end-(start+propertyName.size()+2));
	
	return result;
}

vector <string> FileReader::getAllItemProperties(propertyType pType, string itemName){
	string tag, aux;
	vector<string> result;

	//Get the correct tag string 
	switch(pType){
		case CIRCUIT:
			tag = circuitTag;
		break;
		case PHASE:
			tag = phaseTag;
		break;
		case ZONE:
			tag = zoneTag;
		break;
		case COMPONENTS:
			tag = componentsTag;
		break;
		case DESIGN:
			tag = designTag;
		break;
	}

	//Find the items which start with item name=" and end with "
	int start, end, newStart, limit;
	end = newStart = start = tag.find("<item name=\"" + itemName + "\"", 0);
	newStart += itemName.size() + 13;
	limit = tag.find("</item>", start);

	//Make a list with all properties from that item
	while(start < limit){
		start = tag.find("<property", newStart);
		start = tag.find("=\"", newStart);
		if(start >= limit || start > tag.size())
			break;
		end = tag.find ("\"", start+2);
		newStart = end;
		aux = tag.substr(start+2, end-start-2);
		result.push_back(aux);
	}
	return result;
}