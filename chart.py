import matplotlib.pyplot as plt
import numpy as np
import csv
import sys

# fileName = input("File Name: ")
# magnets = int(input("Number of Magnets: "))

fileName = sys.argv[1]
magnets = int(sys.argv[2])

matrix = []
columns = magnets*3+1

file = open(fileName, 'r')
content = file.readlines()
file.close()

for i in range(columns):
	aux = []
	for line in content:
		parts = line.split(',')
		aux.append(float(parts[i]))
	matrix.append(aux)

for i in range(magnets):
	plt.subplot(magnets, 1, i+1)
	t = np.array(matrix[0])
	x = np.array(matrix[i*3+1])
	y = np.array(matrix[i*3+2])
	z = np.array(matrix[i*3+3])
	plt.plot(t, x, label='X', color = 'b')
	plt.plot(t, y, label='Y', color = 'r')
	plt.plot(t, z, label='Z', color = 'y')
	plt.xlabel("Time")
	plt.ylabel("Magnetization")
	plt.legend()
	plt.ylim(-1.1,1.1)

plt.show()