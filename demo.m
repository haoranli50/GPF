warning off
dbstop if error
clear;
addpath(genpath('.'));

%% Read the data
dataName = 'bbcsport.mat';
load(dataName);
%% Obtain the number of clusters and samples from the data set
view_num = size(X,2);
cluster_num = length(unique(Y));
sample_num = length(Y);
%% Automatically match data (row and column vectors)
if(size(Y,2)~=1)
    Y = Y';
end
if ~isempty(find(Y==0,1))
    Y = Y + 1;
end
for v = 1:view_num
    if size(X{v},2)~=sample_num
        X{v} = X{v}';
    end
    X{v} = NormalizeFea(X{v},0);
end
%% Perform GPF
[C,S,obj,~] = GPF(X,1e-1,10,20);
result = clustering8(S,cluster_num,Y);
%% Clustering result output
ACC = result(7)*100;
NMI = result(4)*100;
ARI = result(5)*100;
fprintf('@ ACC:%5.2f / NMI:%5.2f / ARI:%5.2f \n', ACC,NMI,ARI);