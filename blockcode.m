function blockcode

    % Initialize an empty array to store the binary digits
    id_number=0659;
    id_binary = [];
    
    % Convert the decimal number to binary
    % Continue dividing the number by 2 and storing the remainders
    while id_number > 0
        remainder = mod(id_number, 2); % Calculate the remainder
        id_binary = [remainder, id_binary]; % Prepend the remainder to the array
        id_number = floor(id_number / 2); % Update the decimal number
    end
    
    % If the decimal number is zero, set the binary array to [0]
    if isempty(id_binary)
        binary_array = [0];
    end

    while size(id_binary)<12
        id_binary = [0, id_binary];
    end
    %disp(id_binary);

    %creating the parity check matrix sub matrix
    
    h_parity_matrix = zeros(3,4);
    %disp(h_parity_matrix);

    %adding elements from binary array to this array

    %bin_index = 1;
    %h_index_row=1;
    %h_index_column=1;

   % while bin_index<=12
   %     h_parity_matri(h_index_row, h_index_column) = id_binary(bin_index);
   %     if mod(h_index_column,4)==0
   %         h_index_column=0;
  %          h_index_row=h_index_row+1;
    %    else
   %         h_index_column=h_index_column+1;
   %     end
  %      bin_index=bin_index+1;
%    end
%    disp(h_parity_matrix);
    bin_index = 1;
    h_index_row = 1;
    h_index_column = 1;
    
    while bin_index <= 12
        % Assign the value from id_binary to h_parity_matrix
        h_parity_matrix(h_index_row, h_index_column) = id_binary(bin_index);
        
        % Update the column index
        if mod(h_index_column, 4) == 0
            % Reset column index to 1 and increment row index
            h_index_column = 1;
            h_index_row = h_index_row + 1;
        else
            % Increment the column index
            h_index_column = h_index_column + 1;
        end
        
        % Increment the binary index
        bin_index = bin_index + 1;
    end
    %disp(h_parity_matrix)

    %take taranspose to get g_parity_matrix and h_matrrix
    g_parity_matrix = h_parity_matrix';
    %disp(g_parity_matrix);

    g_matrix = [eye(4),g_parity_matrix];
    h_matrix = [h_parity_matrix,eye(3)];
    %disp(g_matrix);
    disp("H matrix:")
    disp(" ");
    disp(h_matrix);
    codeword_matrix = zeros(16,7);
    % Loop over binary vectors from [0,0,0,0] to [1,1,1,1]
    for vector = 0:15
        % Convert the current vector to a binary vector of length 4
        binary_vector = dec2bin(vector, 4) - '0';
        
        % Convert the binary vector to a column matrix
        %column_vector = binary_vector';
        %row=1; column=1; iterator=1;
        result = [];
        for column_number = 1:7
            current_column = g_matrix(:, column_number);
            temp=0;
            for index = 1:4
                temp = xor(temp,binary_vector(index)*current_column(index));
            end
            result = [result,temp];
        end
        %disp(current_column);
        
        % Perform matrix multiplication
        %result = binary_vector*g_matrix ;
        
        % Display the result of the matrix multiplication
        %disp(binary_vector);
        %disp(result);
        %disp("---------------------");
        codeword_matrix(vector+1,:) = result;
    end
    disp("Transmitted code word matrix:");
    disp(" ");
    %disp(codeword_matrix);

    for row = 1:16
        current_row = codeword_matrix(row,:);
        hd = sum(current_row);
        fprintf('    %s , hamm. dist. = %d\n', num2str(current_row), hd);
    end

    %calculatimg dmin
    
    dmin=7;
    
    for row_number = 2:16
        temp_row = codeword_matrix(row_number,:);
        hd = 0;
        for i = 1:7
            if temp_row(i)==1
                hd=hd+1;
            end
        end
        if hd<dmin
            dmin=hd;
        end
    end
    disp(" ");
    disp("Dmin is : "+ dmin);
    %calculating syndrome vectors for each transmitted codeword
    syndrome_matrix = ones(16,3);
    result = [];
    for row_number = 1:16
            received_codeword = codeword_matrix(row_number,:);
            temp=0;
            for h_matrix_iterator = 1:3
                h_row = h_matrix(h_matrix_iterator,:);
                 for index = 1:7
                    temp = xor(temp,received_codeword(index)*h_row(index));
                 end
                 result = [result,temp];
                 temp=0;
            end
            %disp(result);
            syndrome_matrix(row_number,:)=result;
            result=[];
    end
    %disp(syndrome_matrix);
    disp("syndrome matrix for generated code words: ");
    disp(" ");
    for row = 1:16
        current_row = syndrome_matrix(row,:);
        fprintf('    %s\n',num2str(current_row));
    end

    %nnow finding coreword for last 4 digits of id number

    word_to_code = id_binary(end-3:end);
    index = 0;
    for i = 1:4
        index=index+word_to_code(i)*(2^(4-i));
    end
    %disp(index);
    codeword = codeword_matrix(index+1,:);
    disp(" ");
    disp("Transmitted codeword is: "+num2str(codeword));
    if codeword(4) == 1
        codeword(4) = 0;
    else 
        codeword(4) = 1;
    end
    disp(" ");
    disp("Received codeword is: "+num2str(codeword));
    %codeword = [0,0,0,1,0,0,0];
    %calculate syndrome of this codeword
    temp=0;
    result = [];
    for h_matrix_iterator = 1:3
        h_row = h_matrix(h_matrix_iterator,:);
         for index = 1:7
            temp = xor(temp,codeword(index)*h_row(index));
         end
         %disp(temp);
         result = [result,temp];
         temp=0;
    end
    %disp(result);
    %syndrome_matrix(row_number,:)=result;
    %result=[];
    disp(" ");
    disp("Syndrome of the received codeword is: "+num2str(result));
    disp(" ");
    received_word_syndrome = result;
    %calcaulting syndrome for every possible one bit errors;
    
    error_syndrome_matrix = zeros(7,3);
    error_matrix = eye(7);
    result=[];
    for row_number = 1:7
            error_word = error_matrix(row_number,:);
            temp=0;
            for h_matrix_iterator = 1:3
                h_row = h_matrix(h_matrix_iterator,:);
                 for index = 1:7
                    temp = xor(temp,error_word(index)*h_row(index));
                 end
                 result = [result,temp];
                 temp=0;
            end
            %disp(result);
            error_syndrome_matrix(row_number,:)=result;
            result=[];
    end
    %disp(error_syndrome_matrix);
    disp("Syndrome for every possible 7 bit error vector assuming only one bit error: ");
    disp(" ");
    for row = 1:7
        current_row = error_syndrome_matrix(row,:);
        fprintf('    %s\n',num2str(current_row));
    end

    error_position = 1;

    while((~all( received_word_syndrome == error_syndrome_matrix(error_position,:))) && error_position<=8)
        error_position=error_position+1;
    end
    disp(" ");
    disp("The error is in bit number "+error_position+" from the right");
end
