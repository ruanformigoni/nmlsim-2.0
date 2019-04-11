#include "FileReader.h"

FileReader::FileReader(string filePath){
	char aux;
	ifstream myFile (filePath.c_str());
	while(myFile.get(aux))
		this->content += aux;
	removeComments();
	splitTags();
	myFile.close();
}

void FileReader::removeComments(){
	int start, end;
	start = end = 0;
	while(start < this->content.size()){
		start = this->content.find("<!--", start);
		if(start >= this->content.size())
			break;
		end = this->content.find("-->", start);
		if(start >= this->content.size())
			break;
		this->content.erase(start, end-start+3);
	}
}

void FileReader::splitTags(){
	int start, end;
	start = this->content.find("<circuit>", 0);
	end = this->content.find("</circuit>", start);
	this->circuitTag = this->content.substr(start+10, end-start-10);
	this->content.erase(start, end-start+10);

	start = this->content.find("<clockZone>", 0);
	end = this->content.find("</clockZone>", start);
	this->zoneTag = this->content.substr(start+12, end-start-12);
	this->content.erase(start, end-start+12);
	
	start = this->content.find("<clockPhase>", 0);
	end = this->content.find("</clockPhase>", start);
	this->phaseTag = this->content.substr(start+13, end-start-13);
	this->content.erase(start, end-start+13);

	start = this->content.find("<components>", 0);
	end = this->content.find("</components>", start);
	this->componentsTag = this->content.substr(start+13, end-start-13);
	this->content.erase(start, end-start+13);

	start = this->content.find("<design>", 0);
	end = this->content.find("</design>", start);
	this->designTag = this->content.substr(start+9, end-start-9);
	this->content.erase(start, end-start+9);
}

simulationType FileReader::getEngine (){
	string aux = "";
	int start, end;
	start = this->circuitTag.find("engine=\"", 0);
	end = this->circuitTag.find("\"", start+9);
	aux = this->circuitTag.substr(start+8, end-(start+8));

	if(aux == "LLG")
		return LLG;
	if(aux == "Behaviour")
		return THIAGO;
}

simulationExecution FileReader::getSimMode (){
	string aux = "";
	int start, end;
	start = this->circuitTag.find("simulationMode=\"", 0);
	end = this->circuitTag.find("\"", start+17);
	aux = this->circuitTag.substr(start+16, end-(start+16));

	if(aux == "direct")
		return DIRECT;
	if(aux == "exaustive")
		return EXAUSTIVE;
	if(aux == "verbose")
		return VERBOSE;
}

string FileReader::getProperty(propertyType pType, string propertyName){
	string result, tag;

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

	int start, end;
	start = tag.find(propertyName + "=\"", 0);
	end = tag.find("\"", start+propertyName.size()+2);
	result = tag.substr(start+propertyName.size()+2, end-(start+propertyName.size()+2));
	
	return result;
}

vector<string> FileReader::getItems(propertyType pType){
	string tag, aux;
	vector<string> result;

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

	int start, end, limit;
	start = tag.find("<item name=\"" + itemName + "\"", 0);
	limit = tag.find("</item>", start);
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

	int start, end, newStart, limit;
	end = newStart = start = tag.find("<item name=\"" + itemName + "\"", 0);
	newStart += itemName.size() + 13;
	limit = tag.find("</item>", start);
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