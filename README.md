# FidgieQlickr
## an IoT project that wirelessly receives analog and digital data from hardware components embedded in a custom fidget toy to analyze usage, frequency, stress levels, emotions etc based on user input and the data will be displayed on an app with a visually appealing UI.

### Components
#### 1. 3D Model of Fidget Toy Protoype
The 3D model of the fidget toy prototype was designed on `SolidWorks` based on the dimensions of an `ESP32 board`. The prototype contains:
1. 1 Clicker Button
1. 1 Slider (Slide Potentiometer)
1. 1 Joystick
1. 5 LED embedded Push Buttons
1. 1 On/Off Button
1. 1 On/Off Status LED
1. 1 ESP32 Board with Bluetooth and WiFi Capabilities

All .sldprt and .sldasm files are availble in the `Clicker Prototype CAD Files.zip` file

#### 2. UI Layout For App
Figma was used as the primary tool to develop the UI for the App. Check out the project [here]((https://www.figma.com/community/file/1145501936443574620))
https://www.figma.com/community/file/1145501936443574620


#### 3. Code ESP32 Board to Interface with Hardware Components and Send Data to Web Server
The first part of the code involves setting up the ESP32 board to interact with the hardware components. In considerationn of the time limit, we made the decision to only obtain data from the slider (i.e. slide potentiometer) and the clicker (i.e push button). The push button idenitier set as the number `1` and the identifier for the slide potentiometer was the number `2`. These two numbers willl be used to identify what components the data is coming from
[insert picture]

The setup also involves connecting the board to WiFi and initializing a Web Server, where the data will be sent to.

[insert code]

the second part of the code involves sending usuable data to the web server that will be analyzed to create useful data insights for the user. The push button will always return either 1 or 0, depending on whether the button is pressed or not. The potentiometer will return a value between 0-1023 which will be mapped down to a scale of 0-10. In this context, the potentiometer value refers to how much the slider has been moved. The desired data output is as follows:
```txt
1 2425  1
2 2426  5
1 2523  1
2 2526  9
...
```
where the first column contains the identifier, the second column contains the timestamp and the thrid column contains the value received.


#### 4. Analyze Data 
After each use, the web server receives the data. Due to time consideration and the complexity to intergrating MATLAB and a web server together. We made an assumption that the MATLAB sketch will open a .txt document.
The sketch analyzes the txt file by spilting the data into two arrays based on the identifier, 1 or 2.

```matlab
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
```


After manipulating the timestamps into more a usuable form, the `Slider Position` Graph is plotted. This essentially is a `time-displacement graph` of the slider. By taking the derivative of this graph, we calculated the speed of the slider as time goes on. This data will be presented to the users in a more visualling appealing manner

```matlab
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
```



Similarly, the raw data for the push button was plotted against time. This graph oscillates between 1 and 0, indicating whether the button was pressed or not at a given moment in time. By taking the absolute derivative of this graph, we obtained the number of changes. We calculated the frequency of clicker pressses per second and called it the `Clicker Intensity`. Again, the data plotted will be provided to the users

```matlab
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
```

An example of the data plots produced by the scripts is available in the files.


#### 5. Create App Using React

The app for Fidgie Qlickr was created on React Native, using JavaScript. The app consists of simple elements such as text, images, buttons, input text and scrolling view options.


```javascript

import React from 'react';
import { Text, TextInput, ScrollView, Image, StyleSheet } from 'react-native';
import Constants from 'expo-constants';
const fidgieQlickApp = () => {
  return (
    <ScrollView style={styles.container}>
    <Image
        source={{uri: "https://scontent.xx.fbcdn.net/v/t1.15752-9/299217304_311845934482429_3543354581861281085_n.png?stp=dst-png_p403x403&_nc_cat=111&ccb=1-7&_nc_sid=aee45a&_nc_ohc=SbU1Pl5BBUQAX-sQ9_D&_nc_ad=z-m&_nc_cid=0&_nc_ht=scontent.xx&oh=03_AVLcQUWhvfBWVx0EMx_Ha35kGzM2Y8efbN6qdHRApvemVg&oe=633170F9"}}
        style={{width: 335, height: 265}}
      />
      <Text style={styles.paragraph}> Hello, this is Fidgie Qlickr! Your personal toy and app to help track your emotions </Text>
    
      <TextInput
        style={{
          height: 50,
          borderColor: 'gray',
          backgroundColor: '#fde85d',
          borderWidth: 1
        }}
        defaultValue="Enter Your Name: "
      />
    

  </ScrollView>
  );
}
export default fidgieQlickApp;
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingTop: Constants.statusBarHeight,
    backgroundColor: '#c4f4fd',
    padding: 8,
  },
  paragraph: {
    margin: 35,
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
```
Within my code I was able to change the background colour to fit the theme of Fidgie Qlickr as well as centre the text, images and input boxes for better UI/UX.
I was also able to allow for better UI/UX using a scrolling view so all the information on the app could fit on one page. On this first page, I was able to receive input from the user using the TextInput, although due to time constraints I was not able to store them anywhere meaningful.

``` javascript


import React, { useState } from "react";
import { Button, Text, View, Image, StyleSheet} from "react-native";
import Constants from 'expo-constants';
const Feeling = (props) => {
  const [isFeeling, setIsFeeling] = useState(true);
  return (
    <View style={styles.container}>
    <Text> </Text>
     <Text>Optional: Please declare if you are affected by: </Text>
      <Text>
        {props.name}{isFeeling ? "" : " and I am comfortable with sharing!"}
      </Text>
      <Button
      color="#7d84b2"
        onPress={() => {
          setIsFeeling(false);
        }}
        disabled={!isFeeling}
        title={isFeeling ? "I do experience this!" : "Thank you for the response!"}
      />
    </View>
  );
}
const App = () => {
  return (
    <>
      <Feeling name="ADHD" />
      <Feeling name="ADD" />
      <Feeling name="Anxiety" />
    </>
  );
}
export default App;
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingTop: Constants.statusBarHeight,
    backgroundColor: '#c4f4fd',
    padding: 8,
  },
  paragraph: {
    margin: 24,
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
```
Within this second page the user can choose to identify themselves as a person that experiences ADHD/ADD/anxiety, for data collection purposes. This identification is done by clicking a button which then changes the initial prompt and button text to indicate to the user that their action was recorded.


``` javascript

import React from 'react';
import { StyleSheet, Button, View, SafeAreaView, Text, Alert, TextInput } from 'react-native';
const Separator = () => (
  <View style={styles.separator} />
);
const App = () => (
  <SafeAreaView style={styles.container}>
    <View>
      <Text style={styles.title}>
        Please select your reasons for using the Fidgie Qlickr .
      </Text>
      <Button
        title="Calm Nerves"
        color = "#7d84b2"
        onPress={() => Alert.alert('Response Received')}
      />
    </View>
    <Separator />
    </View>
  </SafeAreaView>
);
const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fde85d',
    flex: 1,
    justifyContent: 'center',
    marginHorizontal: 16,
  },
  title: {
    textAlign: 'center',
    marginVertical: 8,
  },
  fixToText: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  separator: {
    marginVertical: 8,
    borderBottomColor: '#737373',
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
});
export default App;
```
This third page helps to understand the intentions ang goals of the user better by taking information via buttons and text inputs. The buttons used on this page are show that the users response was recorded via a flashing of the button pressed and a confirmation alert of  the response taken.


The fourth page takes the data from the user via text inputs to determine which feature of the Fidgie Qlicker the user believes they will use most frequently. 

The last page is to wrap up the user experience and help the user see the possible change in data of before and after usage of Fidgie Qlickr. All of the data taken from this page is via Text Input.



