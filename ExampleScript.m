%% Example


% path to cpp file
CppDir = 'C:\Users\u0088756\Documents\FWO\Software\GitProjects\CreateDll_PredSim';  % directory of cpp file
Name = 'PredSim_v2_Bram'; % name of the CPP file

% additional path information
OsimSource = 'C:\opensim-ad-core-source';   % source code of opensim (with AD)
OsimBuild = 'C:\GBW_MyPrograms\opensim-ad-core-build2';    % build of opensim
DllPath = 'C:\Users\u0088756\Documents\FWO\Software\ExoSim\SimExo_3D\3dpredictsim\ExternalFunctions'; % copies .dll file to this directory
ExtFuncs = 'C:\opensim-ExternalFunc';           % directory where you build the binaries for the external functions
VSinstall = 'C:\Program Files (x86)\Microsoft Visual Studio 14.0';  % directory installation visual studio
Compiler = 'Visual Studio 14 2015 Win64';       % compiler 

% number of input arguments for external function
nInputDll = 93;

% add this path to your matlab path
addpath(pwd);

% create the dll file
CreateDllFileFromCpp(CppDir,Name,OsimSource,OsimBuild,DllPath,ExtFuncs,VSinstall,nInputDll,Compiler)

