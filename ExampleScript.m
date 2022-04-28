%% Example


% path to cpp file
CppDir = 'C:\Users\mat950\Documents\Software\Sim\CreateDll_PredSim';  % directory of cpp file
Name = 'PredSim_vTest'; % name of the CPP file

% additional path information
OsimSource = 'C:\opensim-ad\opensim-ad-core';   % source code of opensim (with AD)
OsimBuild = 'C:\opensim-ad\build';    % build of opensim
DllPath = 'C:\Users\mat950\Documents\Software\Sim\CreateDll_PredSim'; % copies .dll file to this directory
ExtFuncs = 'C:\opensim-ad\ExternalFuncInst';           % directory where you build the binaries for the external functions
VSinstall = 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community';  % directory installation visual studio
% Compiler = 'Visual Studio 15 2017 Win64';       % compiler 
Compiler = 'Visual Studio 15 2017';       % compiler 

% number of input arguments for external function
nInputDll = 93;

% add this path to your matlab path
addpath(pwd);

% create the dll file
CreateDllFileFromCpp(CppDir,Name,OsimSource,OsimBuild,DllPath,ExtFuncs,VSinstall,nInputDll,Compiler)

