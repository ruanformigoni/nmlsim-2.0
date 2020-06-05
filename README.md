# NMLSim  
A CAD and simulation tool for in-plane nanomagnetic logic circuits.

[Lucas A. Lascasas Freitas](mailto:lucas.freitas@dcc.ufmg.br)  
[Matheus G. Arraes Veloso](mailto:)  
[Thiago R. B. S. Soares](mailto:thiagorbss@dcc.ufmg.br)  
[Omar P. Vilela Neto](mailto:omar@dcc.ufmg.br)  
Department of Computer Science  
Universidade Federal de Minas Gerais  
Belo Horizonte, Brazil

[João G. Nizer Rahmeier](mailto:joaonizer@ufmg.br)  
[Luiz G. C. Melo](mailto:lgcmelo@gmail.com)  
Department of Electrical Engineering  
Universidade Federal de Minas Gerais  
Belo Horizonte, Brazil

## How to RUN the code:

Erase obj files and exe:        <code>make clean</code>  
Erase csv files in File folder: <code>make eraseCSV</code>  
Compile:                        <code>make</code>  
Run engine:                     <code>make run input=inFilePath output=outFilePath</code>  
Run chart script:               <code>python3 chart.py -h</code>  
Run user interface 32 bits system: <code>make interface32</code>  
Run user interface 64 bits system: <code>make interface64</code>  

## Input File Example:
Check /Files/example.xml for more info.

## Link for the Stable Finished Version:
https://drive.google.com/open?id=1YgI6kzAOtzXUtR_I18lkZJhlpwFkR3Lm

## Publications:
1. Soares, T.R.B.S., Nizer Rahmeier, J.G., de Lima, V.C. et al. J Comput Electron (2018) 17: 1370. https://doi.org/10.1007/s10825-018-1215-8

2. Freitas, Lucas A. Lascasas, Omar P. Vilela Neto, João G. Nizer Rahmeier, and Luiz GC Melo. "NMLSim 2.0: a robust CAD and simulation tool for in-plane nanomagnetic logic based on the LLG equation." In Proceedings of the 32nd Symposium on Integrated Circuits and Systems Design, p. 23. ACM, 2019.
