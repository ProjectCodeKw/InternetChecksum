% casses score:
%no_error = index 0;
%detectable_error = index 1;
%undetectable_error = index 2;
%Odd Data = index 3;
%Even Data = index 4;

% get the number of errrors:
iterations = 1000;
num_of_errors = randi([0, iterations], 1, 1); 
disp(["Number of Errors Ganerated", num_of_errors]);

undetectable_error_mat = [0,0,0,0,0];

undetectable_error_mat(1,1) = main_program(9,num_of_errors,iterations);
undetectable_error_mat(1,2) = main_program(12,num_of_errors,iterations);
undetectable_error_mat(1,3) = main_program(15,num_of_errors,iterations);
undetectable_error_mat(1,4) = main_program(18,num_of_errors,iterations);
undetectable_error_mat(1,5) = main_program(21,num_of_errors,iterations);

figure;
x = ["9", "12", "15", "18", "21"];
y = (undetectable_error_mat/sum(undetectable_error_mat))*100;
bar(x,y);
title("Undetectable Error VS Frame Size ");
xlabel("Frame Size");
ylabel("Percantage");


function undetectable_error = main_program(L,num_of_errors,iterations)
    counter=1;
    casses_mat = [0,0,0,0,0];
    og_data = [];
    reciver_data = [];
    
    while counter < iterations+1
        for i = 1:floor(L/3)
            og_data = [og_data; randi([0, 1], 1, 3)];   
               
        end

        if num_of_errors > 0
            % bits flipped are 1:
            % make bits flipped to a matrix of rows, each row is 3-bit word
            flipped_matrix = randi([0, 1], size(og_data));

            % now mask the og matrix with the xor using the flipped bits
            reciver_data =  xor(flipped_matrix, og_data);   
            num_of_errors = num_of_errors - 1;
        else
             reciver_data = og_data;
        end   

        updated_casses = checkSum_CI(og_data, reciver_data);

        casses_mat(1,1) = updated_casses(1,1) + casses_mat(1,1);
        casses_mat(1,2) = updated_casses(1,2) + casses_mat(1,2);
        casses_mat(1,3) = updated_casses(1,3) + casses_mat(1,3);
        casses_mat(1,4) = updated_casses(1,4) + casses_mat(1,4);
        casses_mat(1,5) = updated_casses(1,5) + casses_mat(1,5);
        

        counter = counter+1;

    end
    
    figure;
    x = ["No Error", "Detectable Error", "Undetectable Error", "Odd Data", "Even Data"];
    y = (casses_mat/iterations)*100;
    bar(x,y);
    title(strcat("Coparison between the casses of ", num2str(L)));
    xlabel("Casses");
    ylabel("Percantage");

    disp(["For L = ",L])
    disp(["No Error", casses_mat(1,1)]);
    disp([ "Detectable Error", casses_mat(1,2)]);
    disp(["Undetectable Error", casses_mat(1,3)]);
    disp(["Odd Data", casses_mat(1,4)]);
    disp(["Even Data", casses_mat(1,5)]);
    disp("************************************")

    undetectable_error = casses_mat(1,3);

end

function cases_mat = checkSum_CI(data, reciver_data)
% Convert binary matrix to decimal matrix if needed
og_data = data; % 3-BIT WORDS   

%number of bits in each segment (row) of data
m = 3; % 3-bit word
mod_base = (2^m)-1;

% convert the data to strings then integers then sum them
data_int = bin2dec(num2str(og_data));
total_sum = sum(data_int);

%get modulus
mod_sum = mod(total_sum, mod_base);
parity_int = -mod_sum+mod_base;
%convert parity bits to binary
parity_bits = str2num(dec2bin(parity_int));
parity_matrix = [floor(parity_bits/100), floor(mod(parity_bits, 100)/10), mod(parity_bits, 10)];
reciver_data = [reciver_data; parity_matrix];
cases_mat = detectError(reciver_data, og_data, mod_base);

end

function cases_mat = detectError(reciver_data, og_data, mod_base)
    % this function recieves a data as a matrix of m bit rows
    % this function will print the decoded msg and will compare it to the
    % origianl information.

    cases_mat = [0,0,0,0,0];

   % convert the binary matrix to a matrix of numbers then sum the rows 
    num_matrix = [];

    % Get the number of rows and columns
    numRows = size(reciver_data, 1);
    numCols = size(reciver_data, 2);
    num = 0;

    % Loop through the matrix
    for i = 1:numRows
        for j = 1:numCols
            % Access each element using indices i and j
            current_element = reciver_data(i, j);
            
            % assemble the 3-bit word by adding the each bit
            num = num + (current_element*2^(3-j));
        end

        % append number to the new numbers matrix
        num_matrix = [num_matrix; num];
        num = 0;
    end

    % get the sum of the matrix:
    total_sum = sum(num_matrix);  
    
    
    % detect the error
    error_detected = mod(total_sum, mod_base);

    % check if there is actually an error:
    actual_error = 1; % initital case there is an error
    if og_data == reciver_data(1:end-1, :)
        %no error found
        actual_error = 0;
    end

    % if the check = zero then no error deteted
    if error_detected~=0
        % an error was detected -> update casses matrix 
        cases_mat(1,2) = 1;
    end

    % the case where an error was not detected:
    if actual_error == 1 & error_detected == 0
        cases_mat(1,3) = 1;
    end
    
    % the case where no errors where found
    if actual_error == 0
        cases_mat(1,1) = 1;
    end

    %check if og data is EVEN or ODD -> check last bit in the last row
    number_of_ones = 0;

    % Get the number of rows and columns
    numRows = size(og_data, 1);
    numCols = size(og_data, 2);

    % Loop through the matrix
    for i = 1:numRows
        for j = 1:numCols
            if og_data(i, j) == 1
                number_of_ones = number_of_ones +1;
            end
        end
    end

    if mod(number_of_ones, 2) == 0
        % Data is EVEN
        cases_mat(1,5) = 1;
    else
        % Data is ODD
        cases_mat(1,4) = 1;
    end
    

end