#include <WiFi.h> //required to connect ESP32 to wifi network
#include <WebSerial.h> //provides easy methods to build web-based serial monitor
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

AsyncWebServer server(80); //initializes object on port 80 to set up web server

const char* ssid = "REPLACE_WITH_YOUR_SSID";          // Your WiFi SSID
const char* password = "REPLACE_WITH_YOUR_PASSWORD";  // Your WiFi Password

//hardware constants
const int buttonPin = 12;
const int potPin = A0;

//software variables
int buttonNew;
int buttonIdentity = 1;
int potIdentity = 2;
int potNew;
float potNewG;

unsigned long currentMillis;
int delayTime = 100;

//function receives incoming messages sent from web serial monitor
//message is saved to 'd' variable
//message is printed to web serial
void recvMsg(uint8_t *data, size_t len){
  WebSerial.println("Received Data...");
  String d = "";
  for(int i=0; i < len; i++){
    d += char(data[i]);
  }
  WebSerial.println(d);
}

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

void loop() {
  //reading and sending values from button
  buttonNew = digitalRead(buttonPin);
  currentMillis = millis();
  WebSerial.print(buttonIdentity);
  WebSerial.print(" ");
  WebSerial.print(currentMillis);
  WebSerial.print(" ");
  WebSerial.println(buttonNew);

  //reading and sending values from potentiometer
  potNew = analogRead(potPin);
  potNewG = (10./1023.)*potNew;
  currentMillis = millis();
  WebSerial.print(potIdentity);
  WebSerial.print(" ");
  //WebSerial.print(currentMillis);
  WebSerial.print(" ");
  WebSerial.println(potNewG);
  delay(delayTime);
}


//serial monitor code reference https://randomnerdtutorials.com/esp32-webserial-library/#demonstration-1
