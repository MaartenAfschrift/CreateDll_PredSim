function [] = generate_foo_jac(nInput,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(varargin)
    CurrentPath = pwd;
	datapath = varargin{1};
    cd(datapath);
end

import casadi.*
cg = CodeGenerator('foo_jac');
% arg should have the dimensions of the combined inputs of F, i.e. NX + NU
arg = SX.sym('arg',nInput); 
y = foo(arg);
F = Function('F',{arg},{y});
cg.add(F);
cg.add(F.jacobian())
cg.generate();
if ~isempty(varargin)
    cd(CurrentPath);
end
end

