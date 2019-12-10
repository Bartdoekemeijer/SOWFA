function [time,value] = readOOPTdata(fileIn)
% Author: Bart Doekemeijer, date: April 18, 2019 
%
% Description: this function reads turbine output files that have one
% output per turbine per timestep, such as 'powerGenerator' and 
% 'nacelleYaw'.
%

% Read the string data from the file
fileID = fopen(fileIn,'r'); % Open the text file.
textscan(fileID, '%[^\n\r]', 1-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, '%s%s%s%s%[^\n\r]', inf, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID); % Close the text file.

% Convert to relevant turbine information
turbEntries = str2double(dataArray{1}(2:end));
timeEntries = str2double(dataArray{2}(2:end));
valueEntries = str2double(dataArray{4}(2:end));
nTurbs = max(turbEntries)+1;

% Check if the dimensions make sense
if rem(length(turbEntries)/nTurbs,1) ~= 0
    error('The number of rows do not make sense. Is the file currently being written?')
end

% Export the relevant data
time = timeEntries(turbEntries==0); % Take time vector from first turbine
for turbi = 1:nTurbs
    value(:,turbi) = valueEntries(turbEntries==turbi-1);
end

% check consistency
if any(time ~= unique(timeEntries))
    error('There is an inconsistency when exporting the time vector. ')
end
end