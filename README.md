# FidgieQlickr
## an IoT project that wirelessly receives analog and digital data from hardware components embedded in a custom fidget toy to analyze usage, frequency, stress levels, emotions etc based on user input and the data will be displayed on an app with a visually appealing UI.

### Components
#### 1. 3D Model of Fidget Toy Protoype
The 3D model of the fidget toy prototype was designed on `SolidWorks` based on the dimensions of an `ESP32 board`. The prototype contains:
a. 1 Clicker Button
b. 1 Slider (Slide Potentiometer)
c. 1 Joystick
d. 5 LED embedded Push Buttons
e. 1 On/Off Button
f. 1 On/Off Status LED
g. ESP32 Board

All .sldprt and .sldasm files are availble in the `Clicker Prototype CAD Files.zip` file

#### 2. UI Layout For App
Figma was used as the primary tool to develop the UI for the App. Check out the project [here]([url](https://www.figma.com/community/file/1145501936443574620))
https://www.figma.com/community/file/1145501936443574620


#### 3. Code ESP32 Board to Interface with Hardware Components and Send Data to Web Server
The first part of the code involves setting up the ESP32 board to interact with the hardware components. In considerationn of the time limit, we made the decision to only obtain data from the slider (i.e. slide potentiometer) and the clicker (i.e push button). The push button idenitier set as the number `1` and the identifier for the slide potentiometer was the number `2`.
[insert picture]

The setup also involves connecting the board to WiFi and initializing a Web Server, where the data will be sent to.

[insert code]

the second part of the code involves sending usuable data to the web server that will be analyzed to create useful data insights for the user. The push button will always return either 1 or 0, depending on whether the button is pressed or not. The potentiometer will return a value between 0-1023 which will be mapped down to a scale of 0-10. In this context, the potentiometer value refers to how much the slider has been moved. The desired data output is
```txt
1 2425  1
2 2426  5
1 2523  1
2 2526  9
...
```
where the first column contains the identifier, the second column contains the timestamp and the thrid column contains the value received.


#### 4. Analyze Data 
After each use, the web server receives the data. Due to time consideration and the complexity to mesh MATLAB and a web server together. We made an assumption that the MATLAB sketch will open a .txt document
The sketch analyzes the txt file by spilting the data into two arrays based on the identifier

#### 5. Create App Using React
beverly Stuff

