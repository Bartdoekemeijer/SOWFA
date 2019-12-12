the jeroMQ file included in this folder is compiled for the TUDelft DCSC cluster, and may not work on other systems. 
Other users will have to compile JeroMQ for their own platform:

% MATLAB can use zeroMQ, but it is not necessarily so straight-forward. The easiest solution found was
% using "jeroMQ", which can be downloaded from https://github.com/zeromq/jeromq. After installation,
% Update the path below and you should be all set.
%
% For more information, check out:
% https://mathworks.com/matlabcentral/answers/269061-how-do-i-integrate-zeromq-library-with-matlab-i-want-my-matlab-program-to-be-a-subscriber-of-zeromq
%
% Note: to install jeroMQ, you need to have 'maven' installed. When using Maven to install jeroMQ,
% you may run into an error about the unit testing. If so, disable them and run again using
% 'mvn install -DskipTests'
%
% Recommended Java JDK version: 1.8.0_171 (tested by excluding unit tests)
%
%