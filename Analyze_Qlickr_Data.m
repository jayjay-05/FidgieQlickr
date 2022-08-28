clear
data = load('Sample_Data.txt');
identifier = data(:,1);
timestamp = data(:,2);
value = data(:,3);



%Assumption: 1 is an identifier for clicker button data and 2 is a
%identiier for slider data
slider_timestamp_array = timestamp(2:2:end,:);
slider_value_array = value(2:2:end, :);


clicker_timestamp_array = timestamp(1:2:end,:);
clicker_value_array = value(1:2:end, :);

slider_initial_time = slider_timestamp_array(1,1);
slider_timestamp_array = slider_timestamp_array - slider_initial_time;

clicker_initial_time = clicker_timestamp_array(1,1);
clicker_timestamp_array= clicker_timestamp_array - clicker_initial_time;

% Create a plot of all the button presses 
figure;
ln_clicker = plot(clicker_timestamp_array, clicker_value_array);
ln_clicker.LineWidth = 2.5;
ln_clicker.Color = [0.1, 0.2, 0.3];
ylabel("Touch Button State");
xlabel("Time Elasped (ms)")
title("Clicker Instances")

% Create a plot of slider location on a scale of 1-10
figure;
ln_slider = plot(slider_timestamp_array, slider_value_array);
ln_slider.LineWidth =2.5;
ln_slider.Color= [0.4,0.9,0.1];
ylabel("Slider Location");
xlabel("Time Elasped (ms)")
title("Slider Position Vs Time");


%Analyzing the ntestity of slider movement by differentiating the position
%data to calculate the speed of slider movement
%Higher the speed, higher the intensity
speed = diff(slider_value_array)./diff(slider_timestamp_array);
dim = size(speed);
figure;
ln_slider_speed = plot(slider_timestamp_array(2:end), speed);
ln_slider_speed.LineWidth =2.5;
ln_slider_speed.Color= [0.5,0.6,0.3];
ylabel("Slider Speed Intensity");
xlabel("Time Elasped (ms)")
title("Slider Intensity VS Time")


%find frequency of chnage of clicker

changes = diff(clicker_value_array);

dim = size(changes);


num_100seconds = roundn(dim(1,1),1);
num_seconds = num_100seconds/10;
cutoff_rows = dim(1,1) - num_100seconds;

changes = changes(1: end-cutoff_rows);
changes = reshape(changes,10,[]);
changes = abs(changes);

time_seconds_array = zeros(num_seconds,1);
change_frequency_array = zeros(num_seconds,1);
for second=1 : num_seconds
    time_seconds_array(second,1) = second;
    num_changes = sum(changes(:,second)~=0);
    change_frequency_array(second, 1)=num_changes;
end

%Plot Frequency of Clicks
figure;
ln_clicker_frequency = plot(time_seconds_array, change_frequency_array);
ln_clicker_frequency.LineWidth =2.5;
ln_clicker_frequency.Color= [0.7,0.6,0.1];
ylabel("Clicks per second");
xlabel("Time Elasped (s)");
title("Clicker Frequency");

   






