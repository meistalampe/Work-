% function : fpupil
% author: Marie-Claire Herbig
% last changed: 23.08.17
function [diameterRight, diameterLeft,baselineLeft,...
    baselineRight,interpolationRight, ...
    interpolationLeft, MeanRight, MeanLeft, STDRight,STDLeft]=...
    fpupil (diameterRight, diameterLeft,TimeBaseline,...
    samplingfrequency, trigg)
% input:    raw data of the right and the left pupil diameter, sampling
%           frequency, time for baseline, trigger signal
% output:   blinkfree and artefactfree pupil diameter, baseline, Mean and
%           Standarddeviation of the pupil diameter and interpolation rate

startAnalyze = find(trigg,1,'first'); 
TimeBaseline = TimeBaseline *samplingfrequency;
startBaseline = startAnalyze - TimeBaseline;
endBaseline = startAnalyze;
interpolationRight = [];
interpolationLeft = [];
%--------------------------------------------------------------------------
%identifying blinks--------------------------------------------------------
%--------------------------------------------------------------------------
%blinks begin with negative and end with positive gradient 
%indentify the gradient
    gradientRight = diameterRight;
    gradientRight(find(diameterRight ~= -1)) =0;
    gradientRight = diff(gradientRight);
    posRight = find(gradientRight == 1);
    negRight = find (gradientRight == -1);
    % if analyze starts with a blink
    if posRight(1)<negRight(1)
        diameterRight(1)= diameterRight(posRight(1)+1);
        negRight = [1 negRight];
    end
    %if analyze ends with a blink
    if posRight(end)<negRight(end)
        diameterRight(length(diameterRight)) = diameterRight(negRight(length(negRight))-1);
        posRight = [posRight length(diameterRight)];
    end
    gradientLeft = diameterLeft;
    gradientLeft(find(diameterLeft ~= -1)) =0;
    gradientLeft = diff(gradientLeft);
    posLeft = find(gradientLeft == 1);
    negLeft = find (gradientLeft == -1);
    % if analyze starts with a blink
    if posLeft(1)<negLeft(1)
        diameterLeft(1)= diameterLeft(posLeft(1)+1);
        negLeft = [1 negLeft];
    end
    %if analyze ends with a blink
    if posLeft(end)<negLeft(end)
        diameterLeft(length(diameterLeft)) = diameterLeft(negLeft(length(negLeft))-1);
        posLeft = [posLeft length(diameterLeft)];
    end
%Interpoaltion    
%right----------------------------------------------------------------------
for counter1 = 1:(length(posRight)-1) 
    %recognised the pupil diameter to short
    if negRight(counter1+1) - posRight(counter1) < 8
        posRight(counter1) = 0;
        negRight(counter1+1) = 0;
    end
end
posRight(posRight == 0) = [];
negRight(negRight == 0) = [];

for countRight = 1:length(negRight)
    %make sure that in the beginning and the end there are enough samples
    if negRight(countRight) <= 4  
        startInterpolation = negRight(countRight);
        endInterpolation =posRight(countRight) + 8;
    elseif posRight(countRight)+ 8 >= length(diameterRight)
        startInterpolation = negRight(countRight);
        endInterpolation = length(diameterRight) ;
    else % 4 samples before the blink and 8 samples after the blink
        startInterpolation = negRight(countRight) - 4;
        endInterpolation =posRight(countRight) + 8;
    end
    interpolationRight = [interpolationRight startInterpolation:endInterpolation];
    v = [diameterRight(startInterpolation) diameterRight(endInterpolation)];
    x = [startInterpolation endInterpolation];
    xq = [startInterpolation:endInterpolation];
    %linear interpolation
    diameterRight(startInterpolation:endInterpolation) = interp1(x,v,xq,'linear'); 
end
%left----------------------------------------------------------------------
for counter2 = 1:(length(posLeft)-1)
    %recognised the pupil diameter to short
    if negLeft(counter2 + 1) - posLeft(counter2) < 8
        posLeft(counter2) = 0;
        negLeft(counter2 + 1) = 0;
    end
end
posLeft(posLeft == 0) = [];
negLeft(negLeft == 0) = [];
for countLeft = 1:length(negLeft)
    %make sure that in the beginning and the end there are enough samples
    if negLeft(countLeft) <= 4  
        startInterpolation = negLeft(countLeft);
        endInterpolation =posLeft(countLeft) + 8;
    elseif posLeft(countLeft)+ 8 >= length(diameterLeft)
        startInterpolation = negLeft(countLeft);
        endInterpolation = length(diameterLeft) ;
    else % 4 samples before the blink and 8 samples after the blink
        startInterpolation = negLeft(countLeft) - 4;
        endInterpolation =posLeft(countLeft) + 8;
    end
    interpolationLeft = [interpolationLeft startInterpolation:endInterpolation];
    v = [diameterLeft(startInterpolation) diameterLeft(endInterpolation)];
    x = [startInterpolation endInterpolation];
    xq = [startInterpolation:endInterpolation];
    % linear interpolation
    diameterLeft(startInterpolation:endInterpolation) = interp1(x,v,xq,'linear'); 
end 
%Mean and Standarddeviation---------------------------------------------------------------
meanRight = mean (diameterRight);
stdRight = std (diameterRight);
meanLeft = mean (diameterLeft);
stdLeft = std (diameterLeft);
%--------------------------------------------------------------------------
%identifying other artefacts
%--------------------------------------------------------------------------
%e.g.Halfblinks------------------------------------------------------------
%right---------------------------------------------------------------------
%pupildiameter more than 3 standarddeviations away are coded as blinks
gradient2Right = ones(1,length(diameterRight));
for count2Right = 1 :(length(diameterRight))
    if diameterRight(count2Right) < (meanRight-stdRight)
    gradient2Right(count2Right) = 0;
    end
end
gradient2Right = diff(gradient2Right);
neg2Right = find(gradient2Right == -1);
pos2Right = find(gradient2Right == 1);
    if pos2Right(1)<neg2Right(1)
        diameterRight(1)= diameterRight(pos2Right(1)+1);
        neg2Right = [1 neg2Right];
    end
    if pos2Right(end)<neg2Right(end)
        diameterRight(length(diameterRight)) = diameterRight(neg2Right(length(neg2Right))-1);
        pos2Right = [pos2Right length(diameterRight)];
    end
%left--------------------------------------------------------------------------------
gradient2Left = ones(1,length(diameterLeft));
for count2Left = 1:(length(diameterLeft))
    if (diameterLeft (count2Left) < (meanLeft -stdLeft))
    gradient2Left(count2Left) = 0;
    end
end
gradient2Left = diff(gradient2Left);
neg2Left = find (gradient2Left == -1);
pos2Left = find (gradient2Left == 1);
    if pos2Left(1)<neg2Left(1)
        diameterLeft(1)= diameterLeft(pos2Left(1)+1);
        neg2Left = [1 neg2Left];
    end
    if pos2Left(end)<neg2Left(end)
        diameterLeft(length(diameterLeft)) = diameterLeft(neg2Left(length(neg2Left))-1);
        pos2Left = [pos2Left length(diameterLeft)];
    end
%--------------------------------------------------------------------------
%interpolate other artfacts------------------------------------------------
%--------------------------------------------------------------------------
%right---------------------------------------------------------------------
for count3Right = 1:length(neg2Right)
    %make sure that in the beginning and the end there are enough samples
    if neg2Right(count3Right) <= 4  
        startInterpolation = neg2Right(count3Right);
        endInterpolation =pos2Right(count3Right) + 8;
    elseif pos2Right(count3Right)+ 8 >= length(diameterRight)
        startInterpolation = neg2Right(count3Right);
        endInterpolation = length(diameterRight) ;
    else % 4 samples before the blink and 8 samples after the blink
        startInterpolation = neg2Right(count3Right) - 4;
        endInterpolation =pos2Right(count3Right) + 8;
    end
    v = [diameterRight(startInterpolation) diameterRight(endInterpolation)];
    x = [startInterpolation endInterpolation];
    xq = [startInterpolation:endInterpolation];
    diameterRight(startInterpolation:endInterpolation) = interp1(x,v,xq,'linear');
    %linear interpolation
    interpolationRight = [interpolationRight startInterpolation:endInterpolation];
end
%left----------------------------------------------------------------------
for count3Left = 1:length(neg2Left)
    %make sure that in the beginning and the end there are enough samples
    if neg2Left(count3Left) <= 4  
        startInterpolation = neg2Left(count3Left);
        endInterpolation =pos2Left(count3Left) + 8;
    elseif pos2Left(count3Left)+ 8 >= length(diameterLeft)
        startInterpolation = neg2Left(count3Left);
        endInterpolation = length(diameterLeft) ;
    else % 4 samples before the blink and 8 samples after the blink
        startInterpolation = neg2Left(count3Left) - 4;
        endInterpolation =pos2Left(count3Left) + 8;
    end
    v = [diameterLeft(startInterpolation) diameterLeft(endInterpolation)];
    x = [startInterpolation endInterpolation];
    xq = [startInterpolation:endInterpolation];
    diameterLeft(startInterpolation:endInterpolation) = interp1(x,v,xq,'linear');
    %linear interpolation
    interpolationLeft = [interpolationLeft startInterpolation:endInterpolation];
end
diameterRight = smooth(diameterRight);
diameterLeft = smooth(diameterLeft);
%how many interpolated data?
interpolationRight = length(interpolationRight)/length(diameterRight);
interpolationLeft = length(interpolationLeft)/length(diameterLeft);
%baselines and diameters
baselineRight = diameterRight(startBaseline:endBaseline);
baselineLeft = diameterLeft(startBaseline:endBaseline);
diameterRight = diameterRight(startAnalyze:end);
diameterLeft = diameterLeft(startAnalyze:end);
% Mean and Standarddeviations
MeanRight = mean (diameterRight);
MeanLeft = mean(diameterLeft);
STDRight = std (diameterRight);
STDLeft= std (diameterLeft);

end

