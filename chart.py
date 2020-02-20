import matplotlib.pyplot as plt
import numpy as np
import argparse
import csv
import sys
import math

# CLI argument parser
parser = argparse.ArgumentParser(description='Script to build magnetization precession charts for NMLSim 2.0.')
parser.add_argument('--input', help='Path to input csv file. If no path is provided, the program will close.', default='none')
parser.add_argument('--fontsz', help='Size of the font, use integer numbers only.', default='12')
parser.add_argument('--range', help='Range of the chart. Two values separeted with \';\'. Use \'begin\' and \'end\' for these values.', default='begin;end')
parser.add_argument('--magnets', help='A list of magnets ids separeted with \';\' to be in the chart. If no list is provided, the program will close.', default='')
parser.add_argument('--cols', help='The number of columns for the charts.', default='auto')
parser.add_argument('--comps', help='The components of the magnetization separeted with \';\' to be in the chart.', default='x;y;z')
parser.add_argument('--mode', help='The mode of the chart you want for your results. It can be either \'comparative\' or \'split\'', default='split')
args = parser.parse_args()

# Conditions to stop early
if args.input == "none":
	print("No input file provided. Use --input!")
	exit(0)
if args.magnets == '':
	print("No magnets provided. Use --magnets")
	exit(0)
if (not("x" in args.comps)) and (not("y" in args.comps)) and (not("z" in args.comps)):
	print("No components of magnetization provided. Use --comps and no uppercase characters!")
	exit(0)
if args.cols != "auto" and int(args.cols) < 1:
	print("Bad number of columns. Use --cols and integers greater than 0!")
	exit(0)
if int(args.fontsz) < 1:
	print("Bad font size. Use --fontsz and integers greater than 0!")
	exit(0)

# Save the file name on a variable to easy access
fileName = args.input
# Data matrix
matrix = []

# open the file, read and close it
file = open(fileName, 'r')
content = file.readlines()
file.close()

# Get the header
labels = content.pop(0)
labels = labels.split(',')

# List of magnets to plot and the size of this list
magnetsToPlot = args.magnets.split(";")
numberOfMagnets = len(magnetsToPlot)

# Compute number of lines and columns of the matrix
if(args.cols == "auto"):
	columnNumber = math.ceil(numberOfMagnets/5)
	lineNumber = math.ceil(numberOfMagnets/columnNumber)
else:
	columnNumber = int(args.cols)
	lineNumber = math.ceil(numberOfMagnets/columnNumber)

# Check if all magnets exists
for magnet in magnetsToPlot:
	if(not((magnet + "_x") in labels)):
		print("Invalid magnet:", magnet)
		exit(0)

# Set up the start of the series
if(args.range.split(";")[0] == "begin"):
	start = 0
else:
	start = 0
	while(float(args.range.split(";")[0]) > float(content[start].split(',')[0])):
		start+=1
		if start >= len(content):
			print("Problems with bad ranges! Start is too high!")
			exit(0)

# Set up the end of the series
if(args.range.split(";")[1] == "end"):
	end = len(content)-1
else:
	end = len(content)-1
	while(float(args.range.split(";")[1]) < float(content[end].split(',')[0])):
		end-=1
		if end < start:
			print("Problems with bad ranges! End is too low!")
			exit(0)

# Labels of ploted magnets
plotedLabels = []

# Scan the data and build the matrix
for i in range(len(labels)-1):
	# If it is the first index or the magnet id is set to be ploted
	if(i==0 or labels[i][0:-2] in magnetsToPlot):
		# Save the label
		plotedLabels.append(labels[i])
		# Get the data accordingly
		aux = []
		for index in range(start, end):
			parts = content[index].split(',')
			aux.append(float(parts[i]))
		matrix.append(aux)

# Split mode plots each particle in a different chart
if args.mode == 'split':
	# Index of the plot in the figure
	plotIndex = 1
	# For every magnet to plot
	for magnet in magnetsToPlot:
		# Index of the magnet x data
		index = plotedLabels.index(magnet + "_x")
		# Set it up in the grid
		plt.subplot(lineNumber, columnNumber, plotIndex)
		# T series is the time/iteration/combination
		t = np.array(matrix[0])
		# X component
		if("x" in args.comps):
			x = np.array(matrix[index])
			plt.plot(t, x, label=plotedLabels[index], color = 'b')
		# Y component
		if("y" in args.comps):
			y = np.array(matrix[index+1])
			plt.plot(t, y, label=plotedLabels[index+1], color = 'r')
		# Z component
		if("z" in args.comps):
			z = np.array(matrix[index+2])
			plt.plot(t, z, label=plotedLabels[index+2], color = 'y')
		# Set up the x axis label
		plt.xlabel(labels[0], fontsize=int(args.fontsz))
		# Set up the y axis label
		plt.ylabel("Magnetization", fontsize=int(args.fontsz))
		# Set up the legend position
		plt.legend(loc=0, ncol=3, fontsize=int(args.fontsz))
		# Set up the plot superior and inferior limits
		plt.ylim(-1.1,1.1)
		# Update plot index in the figure
		plotIndex += 1
	# Adjust figure configuration and show
	plt.subplots_adjust(left=0.05, right=0.99, top=0.99, bottom=0.05, hspace=0.3)
	plt.show()
# Comparative mode plots all particles in the same chart
elif args.mode == 'comparative':
	# Only one chart
	plt.subplot(1,1,1)
	# "Time" series
	t = np.array(matrix[0])
	# Iterate every magnet
	for magnet in magnetsToPlot:
		# Get the index of the particle
		index = plotedLabels.index(magnet + "_x")
		# X component
		if("x" in args.comps):
			x = np.array(matrix[index])
			plt.plot(t, x, label=plotedLabels[index])
		# Y component
		if("y" in args.comps):
			y = np.array(matrix[index+1])
			plt.plot(t, y, label=plotedLabels[index+1])
		# Z component
		if("z" in args.comps):
			z = np.array(matrix[index+2])
			plt.plot(t, z, label=plotedLabels[index+2])		
	# Set up the x axis label
	plt.xlabel(labels[0], fontsize=int(args.fontsz))
	# Set up the y axis label
	plt.ylabel("Magnetization", fontsize=int(args.fontsz))
	# Set up the legend position
	plt.legend(loc=0, ncol=3, fontsize=int(args.fontsz))
	# Set up the plot superior and inferior limits
	plt.ylim(-1.1,1.1)
	# Adjust figure configuration and show
	plt.subplots_adjust(left=0.05, right=0.99, top=0.99, bottom=0.05)
	plt.show()
