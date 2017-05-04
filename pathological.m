function [InitFunction, CostFunction, FeasibleFunction] = pathological

InitFunction = @PathologicalInit;
CostFunction = @PathologicalCost;
FeasibleFunction = @PathologicalFeasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = PathologicalInit(OPTIONS)

global MinParValue MaxParValue
MinParValue = -100;
MaxParValue = 100;
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = (MinParValue + (MaxParValue - MinParValue + 1) * rand(1,OPTIONS.numVar));
    Population(popindex).chrom = chrom;
end
OPTIONS.OrderDependent = true;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = PathologicalCost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
for popindex = 1 : popsize
    Population(popindex).cost = 0;
    for i = 1 : OPTIONS.numVar-1
        gene1 = Population(popindex).chrom(i);
        gene2 = Population(popindex).chrom(i+1);
        x1 = (gene1 - MinParValue) / (MaxParValue - MinParValue) ;
        x2 = (gene2 - MinParValue) / (MaxParValue - MinParValue) ;
        temp =   0.5+((sin(sqrt(100*x1^2+x2^2)))^2-0.5)/(1+0.001*(x1^2-2*x1*x2+x2^2)^2);
        Population(popindex).cost = Population(popindex).cost + temp;
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = PathologicalFeasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue);
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue);
    end
end
return;