% This script is used to read the binary file produced by the DCA1000
% and Mmwave Studio
% Command to run in Matlab GUI -readDCA1000('<ADC capture bin file>')
% -------------------------------------------------------------------------------------------------------
function [retVal] = read1843Data(fileName, numADCSamples, numRX)

% global variables
% change based on sensor config
numADCBits = 16; % number of ADC bits per sample
numLanes = 2; % do not change. number of lanes is always 2
% -------------------------------------------------------------------------------------------------------

% read .bin file
fid = fopen(fileName,'r');
adcData = fread(fid, 'int16');
fclose(fid);
% -------------------------------------------------------------------------------------------------------

fileSize = size(adcData, 1);
LVDS = zeros(1, fileSize/2);
%combine real and imaginary part into complex data
%read in file: 2I is followed by 2Q
ptr = 1;
for i=1:4:fileSize-1
    LVDS(1,ptr)   = adcData(i)   + 1j*adcData(i+2); 
    LVDS(1,ptr+1) = adcData(i+1) + 1j*adcData(i+3); 
    ptr = ptr + 2;
end

% filesize = 2 * numADCSamples*numChirps
numChirps = fileSize/2/numADCSamples/numRX;
% create column for each chirp
LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
% each row is data from one chirp
LVDS = LVDS.';
% -------------------------------------------------------------------------------------------------------

%organize data per RX
retVal = zeros(numRX,numChirps*numADCSamples);
for r_idx = 1:numRX
    for c_idx = 1:numChirps
        retVal(r_idx,(c_idx-1)*numADCSamples+1:c_idx*numADCSamples) = ...
        LVDS(c_idx,(r_idx-1)*numADCSamples+1:r_idx*numADCSamples);
    end
end
