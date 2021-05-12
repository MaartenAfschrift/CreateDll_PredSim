function [] = CreateDllFileFromCpp(CppDir,Name,OsimSource,OsimBuild,DllPath,ExtFuncs,VSinstall,nInputDll,varargin)
%CreateDllFileFromCpp Runs the workflow described here
%(https://github.com/antoinefalisse/opensim-core/tree/AD-recorder) to add
% new external functions to your opensim installation
%   input arguments:
%       - CppDir: directory of the cpp file
%       - Name: name of the cpp file.
%       - OsimSource: path to opensim source files
%       - OsimBuild: path to opensim build
%       - DllPath: path where you want to save the dll file
%       - ExtFunc: main folder where you save the VS projects for the
%       external functions (intermediate step in the proces)
%       - VS install: directory where you installed visua studio
%       - nInputDll: number of input arguments of your external function.
%       (for inverse dynamics is this tyically ndof*3 [q qd qdd].
%
% authors: Maarten Afschrift (KU Leuven)
Compiler = 'Visual Studio 14 2015 Win64';   % default compiler
if ~isempty(varargin)
    Compiler = varargin{1};
end

if ~exist(fullfile(DllPath,[Name '.dll']),'file')
    % path info
    PathStart = pwd;
    
    %% OpenSim source - external function
    % create folder in the opensim source folder
    ExtFuncPath = fullfile(OsimSource,'OpenSim\External_Functions',Name);
    mkdir(ExtFuncPath);
    
    % create the CMakeList file
    fid = fopen(fullfile(ExtFuncPath,'CMakeLists.txt'),'wt');
    fprintf( fid, '%s\n', ['set(TEST_TARGET ' Name ')']);
    fprintf( fid, '%s\n', 'add_executable(${TEST_TARGET} ${TEST_TARGET}.cpp)');
    fprintf( fid, '%s\n', 'target_link_libraries(${TEST_TARGET} osimSimulation)');
    fprintf( fid, '%s\n', 'set_target_properties(${TEST_TARGET} PROPERTIES');
    fprintf( fid, '%s\n', '    FOLDER "External_Functions")');
    fclose(fid);
    % copy the cpp files
    copyfile(fullfile(CppDir,[Name '.cpp']),fullfile(ExtFuncPath,[Name '.cpp']));
    
    % add the project to the current cmakelist of the the external projects
    CmakeFile = fullfile(OsimSource,'OpenSim\External_Functions','CMakeLists.txt');
%     ListExtFunc = importdata(CmakeFile);
    tempCopy = fullfile(pwd,'CMakeListTempCopy.txt');
    copyfile(CmakeFile,tempCopy);
    delete(CmakeFile)
    
    % write the cmakefile again
    % open file for reading
    fidr = fopen(tempCopy,'r') ;
    % open file for writing
    fidw = fopen(CmakeFile,'w') ;
    % while end of file has not been reached
    while ( ~feof(fidr) )
        % read line from reading file
        str = fgets(fidr) ;
        % match line to regular expression to determine if replacement needed
        match = regexp(str,'endif()', 'match' ) ;
        % if line is to be added
        if (~isempty(match))
            % added line
            CharAdded = ['	add_subdirectory(' Name ')'];
            fprintf(fidw,'%s\n',convertCharsToStrings(CharAdded));
        end
        % write line to writing file
        fwrite(fidw,str);
    end    
    fclose(fidr);
    fclose(fidw);

    %% Add new project to opensim build
    % update visual studio project with cmake
    % go to folder where you want to build the projects
    % then run for example: "cmake C:\sourceTest -G "Visual Studio 14 2015
    % Win64"
    disp('... running cmake to update opensim build');
    cd(OsimBuild);
    TextCommand = ['cmake ' OsimSource ' -G "' Compiler '"'];
    system(TextCommand);
    
    % or run it automatically using devnenv
    % information: devenv mysln.sln /build Debug /project proj1
    disp('... building project in visual studio');
    ExeDevPath = fullfile(VSinstall,'Common7\IDE');
    cd(ExeDevPath);
    TextCommand = ['devenv.exe ' OsimBuild '\OpenSim.sln ' '/Build ' 'RelWithDebInfo ' '/Project ' Name ];
    system(TextCommand);
    
    %% Create executable, foo.m and foo_jac
    
    % - first: create path with cgeneration info:
    CgenDir1 = fullfile(OsimSource,'cgeneration',Name);
    mkdir(CgenDir1);
    
    % - second: run the exectuables and copy foo.m
    disp('... Running exectuble');
    ExePath = fullfile(OsimBuild,'RelWithDebInfo');
    cd(ExePath);
    if exist(fullfile(ExePath,'foo.m'),'file')
        delete(fullfile(ExePath,'foo.m'));
    end
    system([Name '.exe']);
    copyfile(fullfile(ExePath,'foo.m'),fullfile(CgenDir1,'foo.m'));
    delete(fullfile(ExePath,'foo.m'));
    
    % - third: create the foo_jac.m using a matlab function
    disp('... Creating foo_jac.c');
    generate_foo_jac(nInputDll,CgenDir1);
    
    %% Run cmake to build external function project
    
    % First: create the cmake file
    fid = fopen(fullfile(CgenDir1,'CMakeLists.txt'),'wt');
    fprintf( fid, '%s\n', 'cmake_minimum_required (VERSION 2.8)');
    fprintf( fid, '%s\n', 'set (CMAKE_CXX_STANDARD 11)');
    fprintf( fid, '%s\n', ['set(TEST_TARGET ' Name ')']);
    fprintf( fid, '%s\n', 'project(${TEST_TARGET})');
    fprintf( fid, '%s\n', 'add_library(${TEST_TARGET} SHARED foo_jac.c)');
    fprintf( fid, '%s\n', 'install(TARGETS ${TEST_TARGET}');
    fprintf( fid, '%s\n', '	PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE');
    fprintf( fid, '%s\n', '				GROUP_READ GROUP_WRITE GROUP_EXECUTE');
    fprintf( fid, '%s\n', '				WORLD_READ WORLD_EXECUTE');
    fprintf( fid, '%s\n', '	LIBRARY DESTINATION lib');
    fprintf( fid, '%s\n', '	ARCHIVE DESTINATION lib');
    fprintf( fid, '%s\n', '	RUNTIME DESTINATION bin');
    fprintf( fid, '%s\n', '	)');
    fclose(fid);
    
    % second: create folder for external functions
    mkdir(fullfile(ExtFuncs,Name,'build'));
    mkdir(fullfile(ExtFuncs,Name,'install'));
    
    % Run cmake again
    disp('... running cmake to create project external function');
    cd(fullfile(ExtFuncs,Name,'build'));
    TextCommand = ['cmake ' CgenDir1 ' -G "' Compiler '"'];
    system(TextCommand);
    
    
    %% create .dll file using the visual studio
    
    % go to path with executable to run visual studio from command line
    disp('... Build and install external func project in visual studio ');
    cd(ExeDevPath);
    
    % Build and install project in visual studio
    ExtFunc_Build = fullfile(ExtFuncs,Name,'build');
    TextCommand = ['devenv.exe ' ExtFunc_Build '\' Name '.sln /Build ' 'RelWithDebInfo ' '/Project ALL_BUILD' ];
    system(TextCommand);
    TextCommand = ['devenv.exe ' ExtFunc_Build '\' Name '.sln /Build ' 'RelWithDebInfo ' '/Project INSTALL' ];
    system(TextCommand);
    
    %% Copy the .dll files to your predictive simulation folder    
    copyfile(fullfile(ExtFuncs,Name,'build','RelWithDebInfo',[Name '.dll ']),DllPath);
    cd(PathStart);

else
    %% warning message
    disp(['cannot run this function since thef file: ' Name '.dll because is already in your external function folder ', ...
        DllPath '. consider to change the name of this file']);
end



end

