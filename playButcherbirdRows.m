function [] = playButcherbirdRows(struct, extract);

% 'extract' gives you the order to put the phrases in.
% for some reason this order needs to be reversed to display properly.
flippedExtract = extract(:,1);
% persistent variables can be used across all functions within the script
% pt1 and pt2: the first and the second points clicked
% figChildren: this retrieves the 'sub-objects of the current figure'
% orderData:  'CData' or color data can be retrieved from the sub objects,
% the order of phrases is stored in the first row of the CData

% val:  two alternative values assigned (rearrange, listen)
% phrase1 and 2 are unused at the moment


persistent figChildren pt1 pt2 last orderData phrase1 phrase2 val;
% the default value of the selection menu is 'rearrange'
val = 'rearrange'
figChildren = get(gca,'Children');
orderData = get(figChildren,'CData');
orderData(:, 1) = flippedExtract(:,1);
set(figChildren, 'CData', orderData);
set(figChildren,'ButtonDownFcn', @decide);

 set(gcf,'WindowButtonUpFcn',    '',...
         'WindowButtonMotionFcn',      ''     );
     
    function decide(varargin)
%       val = get(hObj,'Value');
      pt = round(get(gca, 'CurrentPoint'))
%       if pt(1) < 100
      if strcmp(val,'rearrange')
          pt1 = pt(3)
          set(n,'ButtonDownFcn', @getSecondClick);
      end
%       if pt(1) > 100
      if strcmp(val,'listen')
          playSong
      end
    end

    function getSecondClick(varargin)
      pt = round(get(gca, 'CurrentPoint'))
      pt2 = pt(3);
      difference = pt2 - pt1;
        orderData_temp = orderData;
        orderData_temp(pt2, :) = orderData(pt1,:);
        if difference > 0
            orderData_temp(pt1:pt2 - 1, :) = orderData(pt1 + 1:pt2, :);
        end
        if difference < 0
            orderData_temp(pt2 + 1:pt1, :) = orderData(pt2:pt1 - 1, :);
        end
        
        orderData = orderData_temp;
        set(n,'CData',orderData);
        set(n,'ButtonDownFcn', @decide);
    end
      

    function playSong(varargin)        
        pt = round(get(gca, 'CurrentPoint'))

        pt1 = pt(3)
        orderData=get(n,'CData');
        fileNum = orderData(pt1,1)
        beginIndex = struct(1).events.beginIndex(fileNum)
        % theres 44100 samples per second in the original file.
        % the data is 1000 samples per second.
        % so there's 1 data sample for every 44 sound samples.
        
        startPoint = 44*(pt(1) + beginIndex-100)
        startPoint/44
        sample = struct(fileNum).original(startPoint:end);
        fadeIn = 0:1/220:219/220;
        size(fadeIn)
        size(sample)
        sample(1:220) = sample(1:220).*fadeIn';
        soundsc(sample,22050*2);

    end

uicontrol('Style', 'popup',...
           'String', 'rearrange|listen',...
           'Position', [0 0 100 50],...
           'Callback', @setmap);
    function setmap(hObj, event)
        val = get(hObj,'Value');
    end

%%%


rowToShiftPrompt = 'Enter the number of the row to shift: ';
whereToMovePrompt = 'Enter the number of the row to shift it to: ';
% getRowToShift
    function getRowToShift()
        pt1 = input(rowToShiftPrompt);
      if isnumeric(pt1)
        move
      end
    end
        
    function move()
        pt2 = input(whereToMovePrompt);
      if isnumeric(pt2)
        difference = pt2 - pt1;
        orderData_temp = orderData;
        orderData_temp(pt2, :) = orderData(pt1,:);
        if difference > 0
            orderData_temp(pt1:pt2 - 1, :) = orderData(pt1 + 1:pt2, :);
        end
        if difference < 0
            orderData_temp(pt2 + 1:pt1, :) = orderData(pt2:pt1 - 1, :);
        end
        
        orderData = orderData_temp;
        set(n,'CData',orderData);
        getRowToShift
      end
     
        
    end

end

        


