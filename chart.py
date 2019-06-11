import matplotlib.pyplot as plt
import numpy as np
import csv
import sys
import math

fileName = sys.argv[1]
argc = len(sys.argv)

matrix = []
columnNumber = math.ceil((argc-2)/5)
lineNumber = math.ceil((argc-2)/columnNumber)

file = open(fileName, 'r')
content = file.readlines()
file.close()

labels = content.pop(0)
labels = labels.split(',')

for i in range(len(labels)-1):
	aux = []
	for line in content:
		parts = line.split(',')
		aux.append(float(parts[i]))
	matrix.append(aux)

for i in range(2, argc):
	index = 0;
	while(labels[index] != (sys.argv[i] + "_x")):
		index += 1
	plt.subplot(lineNumber, columnNumber, i-1)
	t = np.array(matrix[0])
	x = np.array(matrix[index])
	y = np.array(matrix[index+1])
	z = np.array(matrix[index+2])
	plt.plot(t, x, label=labels[index], color = 'b')
	plt.plot(t, y, label=labels[index+1], color = 'r')
	plt.plot(t, z, label=labels[index+2], color = 'y')
	plt.xlabel("Time")
	plt.ylabel("Magnetization")
	plt.legend(loc=0, ncol=3, fontsize="x-small")
	plt.ylim(-1.1,1.1)

plt.show()