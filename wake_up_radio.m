%% 
% Author:- Sankalp B Chandavarkar
% Date:- 26-07-2024

% Here i will be writing code for modified Wake-up-radio
% Find max of the input and updating it and repeating the cycle



% no_of_nodes = input("Enter total number 0f nudoes\n");      %enter no.of nodes
% batteryValues = zeros(1,no_of_nodes);                       %Initialising battery values to zero

% for i = 1:no_of_nodes
%     fprintf("Enter the values of node %d\n",i);
%     batteryValues(1,i) = input(" ");
% end

clc;
batteryValues = [12 , 30 , 15 , 9 , 6];
no_of_nodes = length(batteryValues);

[MAX,Sorted_values] = get_max(batteryValues);             %Calling get_max function to store the respected values
function [max ,sorted_values] = get_max(batteryValues)  %start of the function to find out 1st,2nd and 3rd max nnumbers in the array and also the sorted array
    sorted_values = sort(batteryValues,'descend');
    max = sorted_values(1:3);
end                                                  %end of the get_max function



% this function is used to get the Update time
function Utime = UpdateTime()
    Utime=round(rand(1),1);
end
global k;
global t;
k=1;
t=0;

function [update,history,time] = batteryReduction(MAX,batteryValues)     %start of batteryReduction function
    global k;
    global t;
    j = find(MAX(1) == batteryValues);                      %will find the index of node with high battery value
    while batteryValues(j) >= MAX(2)        %|| batteryValues(j)<=MAX(3)      
        %fuctiot(t) after t sec if will run
        if(randi([0,1]))
            batteryValues(j) = max(batteryValues(j) - 0.3,0);
            for i=1:length(batteryValues)
                if i == j
                    continue
                else 
                    batteryValues(i)=max(batteryValues(i)-0.1,0);
                end
            end
            update=batteryValues;
            history(k,:)=batteryValues
            time(k,1)=t+0.1;
            t=time(k,1);
            k=k+1;
        else
            for i=1:length(batteryValues)
                batteryValues(i)=max(batteryValues(i)-0.1,0);
            end
            update=batteryValues;
            history(k,:)=batteryValues
            time(k,1)=t+0.1;
            t=time(k,1);
            k=k+1;
        end
        
    end
end      %end of batteryReduction function

% function wake_up_radio()
    
    
    
while any(batteryValues)              %start of while loop to reduce the battery
        
    MAX = get_max(batteryValues);
        
    [Update,history,time] = batteryReduction(MAX,batteryValues);
    %
    batteryValues = Update;
end
