function bsc_simulation()
    % Parameters
    min_length = 100;  % Minimum length of binary sequence
    max_length = 20000; % Maximum length of binary sequence
    step = 100;  % Step size
    error_probability = 0.4; % Error probability of the BSC

    % Arrays to store the results
    transmitted_lengths = min_length:step:max_length;
    num_errors = zeros(size(transmitted_lengths));
    error_ratios = zeros(size(transmitted_lengths));

    % Simulate for each length of binary sequence
    for idx = 1:length(transmitted_lengths)
        % Generate a binary sequence of the current length
        sequence_length = transmitted_lengths(idx);
        original_sequence = randi([0, 1], 1, sequence_length);

        % Simulate the BSC
        received_sequence = bsc(original_sequence, error_probability);

        % Calculate the number of errors
        num_errors(idx) = sum(original_sequence ~= received_sequence);

        % Calculate the ratio of errors
        error_ratios(idx) = num_errors(idx) / sequence_length;
    end

    % Plot the number of errors vs. the total number of digits transmitted
    figure;
    plot(transmitted_lengths, num_errors);
    xlabel('Total Number of Digits Transmitted');
    ylabel('Number of Digits in Error');
    title('Number of Digits in Error vs. Total Number of Digits Transmitted');

    % Plot the ratio of errors vs. the total number of digits transmitted
    figure;
    plot(transmitted_lengths, error_ratios);
    xlabel('Total Number of Digits Transmitted');
    ylabel('Error Ratio');
    title('Error Ratio vs. Total Number of Digits Transmitted');
end

% Function to simulate the binary symmetric channel
function received_sequence = bsc(original_sequence, error_probability)
    % Generate random numbers between 0 and 1 for each bit
    random_values = rand(1, length(original_sequence));
    
    % Flip the bits where the random value is less than the error probability
    received_sequence = original_sequence;
    flip_indices = random_values < error_probability;
    received_sequence(flip_indices) = ~original_sequence(flip_indices);
end
