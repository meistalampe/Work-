function [BIT_data] = readTextFile(filename,delimiter,headerSize)

BIT_data = dlmread(filename,delimiter,headerSize);

end