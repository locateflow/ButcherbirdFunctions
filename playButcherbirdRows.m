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


persistent figChildren pt1 pt2 orderData val player val_speed;
player = audioplayer([0 1], 44100);
val_speed = 1;
% the default value of the selection menu is 'rearrange'
% 'rearrange' is 1
val = 1
figChildren = get(gca,'Children');
orderData = get(figChildren,'CData');
% insert the order data into the first row of CData
orderData(:, 1) = flippedExtract(:,1);
set(figChildren, 'CData', orderData);
set(figChildren,'ButtonDownFcn', @decide);

set(gcf,'WindowButtonUpFcn',    '',...
    'WindowButtonMotionFcn',      ''     );
set(gcf, 'KeyPressFcn', @pb_kpf)

% function pb_call(varargin)
% S = varargin{3};  % Get the structure.
% set(S.tx,'String', get(S.pb,'String'))
% % Do same action as button when pressed 'p'
function pb_kpf(varargin)
if varargin{1,2}.Character == 'p'
    if val == 1; val = 2; end
    if val == 2; val = 1; end
end

    function decide(varargin)
        pt = round(get(gca, 'CurrentPoint'))
        val
        if val == 1
            pt1 = pt(3)
            figChildren = get(gca,'Children');
            set(figChildren,'ButtonDownFcn', @getSecondClick);
        end
        if val == 2
            clear playsnd
            clear sound
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
        set(figChildren,'CData',orderData);
        set(figChildren,'ButtonDownFcn', @decide);
    end


    function playSong(varargin)
        pt = round(get(gca, 'CurrentPoint'))       
        pt1 = pt(3)
        figChildren = get(gca,'Children');
        
        orderData=get(figChildren,'CData');
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
        stop(player)
        player = audioplayer(sample,22050*2*val_speed);
        play(player)
        
    end

uicontrol('Style', 'popup',...
    'String', 'rearrange|listen',...
    'Position', [0 0 100 50],...
    'Callback', @setmap);
    function setmap(hObj, event)
        set(figChildren,'ButtonDownFcn', @decide);
        str = 'that was val set by hObj'
        val = get(hObj,'Value')
    end

%%%
uicontrol('Style', 'popup',...
    'String', '0.25|0.50|1.00|2.00',...
    'Position', [0 50 100 50],...
    'Callback', @setspeed, 'Value', 3);
    function setspeed(hObj, event)
        str = 'that was val set by hObj2'
        val_speed = 0.25*2^(get(hObj,'Value')-1)
    end


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




