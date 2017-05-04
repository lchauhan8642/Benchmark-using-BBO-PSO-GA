BIOGEOGRAPHY-BASED OPTIMIZATION

Dan Simon
March 1, 2008
August 12, 2008

web: http://academic.csuohio.edu/simond/
email: d.j.simon@csuohio.edu

The files in this zip archive are Matlab m-files that can be used to study the following optimization methods:

ant colony optimization (ACO)
biogeography-based optimization (BBO)
differential evolution (DE)
evolutionary strategy (ES)
genetic algorithm (GA)
probability-based incremental learning (PBIL)
particle swarm optimization (PSO)
stud genetic algorithm (SGA)

BBO is the method that I invented and wrote about in the following paper:
D. Simon, “Biogeography-Based Optimization,” IEEE Transactions on Evolutionary Computation, in print (2008).
In order to compare BBO with other methods, I had to program those other methods, so I am making them all available in this zip archive.

The Matlab files can be used to reproduce the results in the paper, or to do your own experiments. The paper and the software are available at http://academic.csuohio.edu/simond/bbo. The software is freely available for any purposes (it is on the Internet, after all) although I would of course appreciate an acknowledgement if you use it as part of a paper or presentation

The Matlab files and their descriptions are as follows:

Ackley.m, Fletcher.m, Griewank.m, Penalty1.m, Penalty2.m, Quartic.m, Rastrigin.m, Rosenbrock.m, Schwefel.m, Schwefel2.m, Schwefel3.m, Schwefel4.m, Sphere.m, Step.m - These are the 14 benchmark functions discussed in the paper. You can use these as templates to write your own function if you are interested in testing or optimizing some other function.

ACO.m, BBO.m, DE.m, ES.m, GA.m, PBIL.m, PSO.m, StudGA.m - These are the optimization algorithms compared in the paper. They can be used to optimize some function by typing, for example, the following at the Matlab prompt:
>> ACO(@Step);
This command would run ACO on the Step function (which is codified in Step.m). 

Init.m - This contains various initialization settings for the optimization methods. You can edit this file to change the population size, the generation count limit, the problem dimension, and the mutation probability of any of the optimization methods that you want to run.

ClearDups.m - This is used by each optimization method to get rid of duplicate population members and replace them with randomly generated individuals.

ComputeAveCost.m - This is used by each optimization method to compute the average cost of the population and to count the number of legal (feasible) individuals.

PopSort.m - This is used by each optimization method to sort population members from most fit to least fit.

Conclude.m - This is concludes the processing of each optimization method. It does common processing like outputting results.

MAPSS.m - This is the sensor selection initialization and fitness evaluation function. It requires the Control System Toolbox. You can use any of the optimization algorithms to find an optimal sensor set by typing, for example, the following at the Matlab prompt:
>> PSO(@MAPSS);

matrices.mat - This is used by MAPSS.m and contains linearized system matrices for fitness function evaluation.

Monte.m - This can be used to obtain Monte Carlo simulation results. The first executable line specifies the number of simulations to run. This is the highest-level program in this archive, and is the one that I ran to create the results in the paper that I wrote.

I hope that this software is as interesting and useful to you as is to me. Feel free to contact me with any comments or questions.