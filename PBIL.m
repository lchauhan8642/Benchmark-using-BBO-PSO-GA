function [MinCost] = PBIL(ProblemFunction, DisplayFlag)

% Probability Based Incremental Learning (PBIL) for optimizing a general function.

% INPUTS: ProblemFunction is the handle of the function that returns 
%         the handles of the initialization, cost, and feasibility functions.
%         DisplayFlag says whether or not to display information during iterations and plot results.

if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end

[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction);
MinCost = [];
AvgCost = [];

LearningRate = 0.05; % PBIL learning rate
UpdateFromBest = 1; % number of good population members to use to update the probability vector each generation
UpdateFromWorst = 0; % number of bad population members to use to update the probability vector each generation
Keep = 1; % elitism parameter: how many of the best individuals to keep from one generation to the next
% The 0.5 multiplication factor below seems to be key to getting
% good performance from this PBIL program. It may be an artifact of the
% particular objective function that we're optimizing because it tends to keep the 
% population members in the middle of their allowable ranges.
Factor = 1;%0.5;
pMutate = 0; % probability vector mutation rate
shiftMutate = 0.1; % probability vector mutation shift magnitude
epsilon = 1e-6;
ProbVec = 0.5 * ones(1, OPTIONS.numVar); % initial probability vector

% Begin the evolution loop
for GenIndex = 0 : OPTIONS.Maxgen
    % Generate a population based on the probability vector.
    for popindex = 1 : OPTIONS.popsize
        if (GenIndex == 0) || (popindex > Keep)
            RandVec = Factor * (rand(1,OPTIONS.numVar) - 0.5) + ProbVec;
            RandVec = max(0, min(1-epsilon, RandVec));
            chrom = floor(MinParValue + (MaxParValue - MinParValue + 1) * RandVec);
            Population(popindex).chrom = chrom;
        end
    end
    % Make sure the population does not have duplicates. 
    Population = ClearDups(Population, MaxParValue, MinParValue);
    % Calculate cost
    Population = CostFunction(OPTIONS, Population);
    % Sort from best to worst
    Population = PopSort(Population);
    % Compute the average cost of the valid individuals
    [AverageCost, nLegal] = ComputeAveCost(Population);
    % Display info to screen
    MinCost = [MinCost Population(1).cost];
    AvgCost = [AvgCost AverageCost];
    if DisplayFlag
        disp(['The best and mean of Generation # ', num2str(GenIndex), ' are ',...
            num2str(MinCost(end)), ' and ', num2str(AvgCost(end))]);
    end
    % Probability vector update from best population members
    for k = 1 : UpdateFromBest
        %ProbVec = ProbVec * (1 - LearningRate);
        Adjustment = (Population(k).chrom - MinParValue) / (MaxParValue - MinParValue);
        Adjustment = (Adjustment - ProbVec) * LearningRate;
        ProbVec = ProbVec + Adjustment;
    end
    % Probability vector update from worst population members
    for k = OPTIONS.popsize-UpdateFromWorst+1 : OPTIONS.popsize
        %ProbVec = ProbVec * (1 - LearningRate);
        Adjustment = (Population(k).chrom - MinParValue) / (MaxParValue - MinParValue);
        Adjustment = (ProbVec - Adjustment) * LearningRate;
        ProbVec = ProbVec + Adjustment;
    end
    % Mutation of the probability vector
    for i = 1 : OPTIONS.numVar
        if rand < pMutate
            ProbVec(i) = ProbVec(i) + shiftMutate * (rand < 0.5);
        end
    end
    ProbVec = max(0, min(ProbVec, 1));
end
Conclude(DisplayFlag, OPTIONS, Population, nLegal, MinCost);
if DisplayFlag
    disp(['Probability Vector = ', num2str(ProbVec)]);
end
return;
