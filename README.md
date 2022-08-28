# FidgieQlickr
## An IoT project that wirelessly receives analog and digital data from hardware components embedded in a custom fidget toy to analyze usage, frequency, stress levels, emotions, etc. based on user input, and the data will be displayed on an app with a visually appealing UI.

### Components
#### 1. 3D Model of Fidget Toy Protoype
The 3D model of the fidget toy prototype was designed on `SolidWorks` based on the dimensions of an `ESP32 board`. The prototype contains:
1. 1 Clicker Button
1. 1 Slider (Slide Potentiometer)
1. 1 Joystick
1. 5 LED-Embedded Push Buttons
1. 1 On/Off Button
1. 1 On/Off Status LED
1. 1 ESP32 Board with Bluetooth and WiFi Capabilities

All .sldprt and .sldasm files are availble in the `Clicker Prototype CAD Files.zip` file

#### 2. UI Layout For App
Figma was used as the primary tool to develop the UI for the App. Check out the project here
https://www.figma.com/community/file/1145501936443574620


#### 3. Code ESP32 Board to Interface with Hardware Components and Send Data to Web Server
The first part of the code involved setting up the ESP32 board to interact with the hardware components. In consideration of the time limit, we made the decision to only obtain data from the slider (i.e. slide potentiometer) and the clicker (i.e push button). The push button idenifier was set to the number `1` and the identifier for the slide potentiometer was the number `2`. These two numbers would be used to identify which components the data is coming from.

The setup also involves connecting the board to WiFi and initializing a Web Server, where the data will be sent to.

```C
void setup() {
  Serial.begin(115200);

  //connecting board to local network
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  if (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.printf("WiFi Failed!\n");
    return;
  }
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  //initializing the server
  //WebSerial is accessible at "<IP Address>/webserial" in browser
  WebSerial.begin(&server); //initializes web-based serial monitor
  WebSerial.msgCallback(recvMsg); //callback function that will run recvMsg() whenever message is sent from monitor to board
  server.begin();

  //hardware setup
  pinMode(potPin, INPUT);
}
```

The second part of the code involved sending usuable data to a web server that would be analyzed to create useful data insights for the user. The push button will always return either 1 or 0, depending on whether the button is pressed or not. The potentiometer will return a value between 0-1023 which will be mapped down to a scale of 0-10. In this context, the potentiometer value refers to how much the slider has been moved. The desired data output is as follows:
```txt
1 2425  1
2 2426  5
1 2523  1
2 2526  9
...
```
where the first column contains the identifier, the second column contains the timestamp and the third column contains the value received.


#### 4. Analyze Data 
After each use, the web server receives the data. Due to time considerations and the complexity of intergrating `MATLAB` to a web server, we made the assumption that the `MATLAB` sketch will open a .txt document.
The sketch analyzes the txt file by spliting the data into two arrays based on the identifier, 1 or 2.

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


After manipulating the timestamps into a more usuable form, the `Slider Position` Graph was plotted. The results produced was essentially a `time-displacement graph` of the slider. By taking the derivative of this graph, the speed of the slider was calculated as time went on. This data will be presented to the users in a more visually appealing manner.

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

Similarly, the raw data for the push button was plotted against time. This graph oscillates between 1 and 0, indicating whether the button was pressed or not at a given moment in time. By taking the absolute derivative of this graph, the number of changes was obtained. The frequency of clicker pressses per second was calculated and called the `Clicker Intensity`. Again, the data plotted will be provided to the users.

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


The app for Fidgie Qlickr was created on `React Native`, using `JavaScript`. The app consists of simple interactive elements such as text, images, buttons, input text and scrolling view options.

Within the code to improve the UI/UX, the background colour was adjusted to better fit the theme of Fidgie Qlickr. Other design choices made were centering text, images and input boxes as well as including scrolling view so all information on the app could fit on one page. 

The first page of the app was coded to receive input from the user using the TextInput. Unfortunately due to time constraints, the input from the user was not stored anywhere meaningful in terms of data collection.

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
Through the second page, the user had the option to identify themselves as a person that experiences ADHD/ADD/anxiety, for data collection purposes. This identification is done by the user clicking a button under a prompt; after the button press, the initial prompt and button text changes to indicate to the user that their action was recorded.

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

The third page of the app was designed to help better understand the intentions and goals of the user through app usage by taking information via buttons and text inputs. The buttons used on this page demonstrates that the users response was recorded via flashing of the button that was pressed and a confirmation alert of the response taken.

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

The fourth page collects data via text inputs to determine which features of the Fidgie Qlicker the user believes they will use most frequently. This will help to analyze the Fidgie Qlickr usage as well as serve as documentation for the users fidgeting behaviours.

The last page was used to wrap up the user experience through letting the user reflect on their Fidgie Qlickr usage, which will be used to compare the before and after data. All of the data taken from this page was via Text Input.
