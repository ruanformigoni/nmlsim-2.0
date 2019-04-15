all: nmlsim

nmlsim: Objs/Main.o Objs/Neighbor.o Objs/ThiagoMagnet.o Objs/LLGMagnet.o Objs/LLGMagnetMagnetization.o Objs/dipolar3D3_modificado.o Objs/ClockZone.o Objs/ClockPhase.o Objs/ClockController.o Objs/Circuit.o Objs/Simulation.o Objs/FileReader.o
	@g++ Objs/Main.o Objs/Neighbor.o Objs/ThiagoMagnet.o Objs/LLGMagnet.o Objs/LLGMagnetMagnetization.o Objs/dipolar3D3_modificado.o Objs/ClockZone.o Objs/ClockPhase.o Objs/ClockController.o Objs/Circuit.o Objs/Simulation.o Objs/FileReader.o -o nmlsim -lgfortran

Objs/Neighbor.o: Magnet/Neighbor.cpp Magnet/Neighbor.h Others/Includes.h
	@g++ -std=gnu++11 -c Magnet/Neighbor.cpp -o Objs/Neighbor.o

Objs/ClockPhase.o: Clock/ClockPhase.cpp Clock/ClockPhase.h Others/Includes.h
	@g++ -std=gnu++11 -c Clock/ClockPhase.cpp -o Objs/ClockPhase.o

Objs/ThiagoMagnet.o: Magnet/ThiagoMagnet.cpp Magnet/ThiagoMagnet.h Magnet/Magnet.h Magnet/Neighbor.h Clock/ClockPhase.h Magnet/LLGMagnetMagnetization.h Others/Includes.h Simulator/FileReader.h
	@g++ -std=gnu++11 -c Magnet/ThiagoMagnet.cpp -o Objs/ThiagoMagnet.o

Objs/LLGMagnet.o: Magnet/LLGMagnet.cpp Magnet/LLGMagnet.h Magnet/Magnet.h Magnet/Neighbor.h Clock/ClockPhase.h Others/Includes.h Simulator/FileReader.h
	@g++ -std=gnu++11 -c Magnet/LLGMagnet.cpp -o Objs/LLGMagnet.o

Objs/LLGMagnetMagnetization.o: Magnet/LLGMagnetMagnetization.cpp Magnet/LLGMagnetMagnetization.h Magnet/Magnet.h Magnet/Neighbor.h Clock/ClockPhase.h Others/Includes.h
	@g++ -std=gnu++11 -c Magnet/LLGMagnetMagnetization.cpp -o Objs/LLGMagnetMagnetization.o

Objs/dipolar3D3_modificado.o: Magnet/dipolar3D3_modificado.f90
	@gfortran -c Magnet/dipolar3D3_modificado.f90 -o Objs/dipolar3D3_modificado.o -J ModFiles

Objs/ClockZone.o: Clock/ClockZone.cpp Clock/ClockZone.h Magnet/Magnet.h Clock/ClockPhase.h Others/Includes.h
	@g++ -std=gnu++11 -c Clock/ClockZone.cpp -o Objs/ClockZone.o

Objs/ClockController.o: Clock/ClockController.cpp Clock/ClockController.h Clock/ClockZone.h Clock/ClockPhase.h Others/Includes.h
	@g++ -std=gnu++11 -c Clock/ClockController.cpp -o Objs/ClockController.o

Objs/FileReader.o: Simulator/FileReader.cpp Simulator/FileReader.h Others/Includes.h
	@g++ -std=gnu++11 -c Simulator/FileReader.cpp -o Objs/FileReader.o

Objs/Circuit.o: Simulator/Circuit.cpp Simulator/Circuit.h Clock/ClockController.h Magnet/Magnet.h Clock/ClockZone.h Clock/ClockPhase.h Others/Includes.h
	@g++ -std=gnu++11 -c Simulator/Circuit.cpp -o Objs/Circuit.o

Objs/Simulation.o: Simulator/Simulation.cpp Simulator/Simulation.h Simulator/Circuit.h Clock/ClockController.h Clock/ClockZone.h Clock/ClockPhase.h Magnet/Magnet.h Simulator/FileReader.h Others/Includes.h
	@g++ -std=gnu++11 -c Simulator/Simulation.cpp -o Objs/Simulation.o

Objs/Main.o: Main.cpp Simulator/Simulation.h Others/Includes.h
	@g++ -std=gnu++11 -c Main.cpp -o Objs/Main.o

clean:
	@rm -f Objs/*.o
	@rm -f nmlsim
	@rm -f ModFiles/*.mod

input:="Files/example.xml"
output:="Files/out.csv"

run:
	@./nmlsim $(input) $(output)