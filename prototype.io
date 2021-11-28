#define echoPin 9 // attach pin D9 Arduino to pin Echo of HC-SR04
#define trigPin 10 //attach pin D10 Arduino to pin Trig of HC-SR04

// defines variables
long duration; // variable for the duration of sound wave travel
int distance; // variable for the distance measurement

//include library for LED ring light
#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
 #include <avr/power.h> // Required for 16 MHz Adafruit Trinket
#endif

//set the LED ring light pin and initialize the strip
#define LED_PIN     13
Adafruit_NeoPixel strip = Adafruit_NeoPixel(24, LED_PIN, NEO_GRB + NEO_KHZ800);

//include library for lcd display and set the pins
#include <LiquidCrystal.h>
LiquidCrystal lcd(8, 6, 5, 4, 3,2);

//initialize variables for soil sensor
int sensorPin = A0;
int sensorValue = 0;
int percentValue = 0;


#define UPDATES_PER_SECOND 100

//initialize variables for each state
const int MOISTURE_state = 0;
const int DISTANCE_state = 1;

int currentState = MOISTURE_state;

void setup() {
  // put your setup code here, to run once:
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an OUTPUT
  pinMode(echoPin, INPUT); // Sets the echoPin as an INPUT
  lcd.begin(16, 2);
  Serial.begin(9600); // // Serial Communication is starting with 9600 of baudrate speed
  Serial.println("Ultrasonic Sensor HC-SR04 Test"); // print some text in Serial Monitor
  Serial.println("with Arduino UNO R3");
  delay( 3000 ); // power-up safety delay
  
  #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
  clock_prescale_set(clock_div_1);
  #endif
  // END of Trinket-specific code.

  #if defined (__AVR_ATtiny85__)
    if (F_CPU == 16000000) clock_prescale_set(clock_div_1);
  #endif
  // End of trinket special code

  strip.begin();
  strip.setBrightness(50);
  strip.show(); // Initialize all pixels to 'off'

  enter_MOISTURE(); 

}

long savedMillis;
// in this function, system enters MOISTURE state
void enter_MOISTURE() {
  Serial.println("enter MOISTURE");
  lcd.clear();
  lcd.setCursor(0, 0);
  savedMillis = millis();
}

// here system checks the soil's moisture level. LED ring light shows the level.
void service_MOISTURE() {
   sensorValue = analogRead(sensorPin);
   Serial.print("\n\nAnalog Value: ");
   Serial.print(sensorValue);
   
   percentValue = map(sensorValue, 488, 446, 100, 0); //we map the sensor value to get data as percentage

   if (percentValue > 25 && percentValue < 50) {
    Serial.print("\nPercentValue: ");
    Serial.print(percentValue);
    Serial.print("%");
    lcd.setCursor(0, 0);
    lcd.print("i'm good!I don't");
    lcd.setCursor(0, 1);  
    lcd.print("need water");
    showMoistureLevel(strip.Color(  0, 255,   0), 6);
  
  } 
   else if(percentValue > 50 && percentValue < 75) {
    Serial.print("\nPercentValue: ");
    Serial.print(percentValue);
    Serial.print("%");
    lcd.setCursor(0, 0);
    lcd.print("i'm good!I don't");
    lcd.setCursor(0, 1);  
    lcd.print("need water");
    showMoistureLevel(strip.Color(  0, 255,   0), 9);

  }
  else if(percentValue > 75 && percentValue < 100) {
    Serial.print("\nPercentValue: ");
    Serial.print(percentValue);
    Serial.print("%");
    lcd.setCursor(0, 0);
    lcd.print("i'm good!I don't");
    lcd.setCursor(0, 1);  
    lcd.print("need water");
    showMoistureLevel(strip.Color(  0, 255,   0), 12);

    }
    
  else if(percentValue < 25 && percentValue > 0) { 
    Serial.print("\nPercentValue: ");
    Serial.print(percentValue);
    Serial.print("%");
    lcd.setCursor(0, 0);
    lcd.print("I need");
    lcd.setCursor(0, 1);  
    lcd.print("water!");
    showMoistureLevel(strip.Color(  0, 255,   0), 3);

     }
   //system stays 6 sec in MOISTURE case.After 6 secs it enters DISTANCE state
  if (millis() - savedMillis > 6000) {
    strip.clear();
    currentState = DISTANCE_state;
    enterNewState();
  }

  long timeInMOISTURE = millis() - savedMillis;

  if (timeInMOISTURE < 2000) {
    Serial.println("MOIS 1");
  } else if (timeInMOISTURE < 4000) {
    Serial.println("MOIS 2");
  } else {
    Serial.println("MOIS 3");
  }
}

void enter_DISTANCE() {
  savedMillis = millis();
  Serial.println("enter DISTANCE");
  lcd.clear();
}

//in DISTANCE state, system checks if someone get closer to ultrasonic sensor. If the distance between sensor and someone(or an object) less than 100, LED ring light shows rainbow animation.
void service_DISTANCE() {
  Serial.println("service DISTANCE");
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin HIGH (ACTIVE) for 10 microseconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);
  // Calculating the distance
  distance = duration * 0.034 / 2; // Speed of sound wave divided by 2 (go and back)
  // Displays the distance on the Serial Monitor
  Serial.println();
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");
 
  if (distance < 100 && distance > 0) {
      rainbowCycle(5);
      strip.clear();
      }
      
    if (millis() - savedMillis > 5000) {
    strip.clear();
    currentState = MOISTURE_state;
    enterNewState();
  }
}

// this function provides us switching between the two cases
void enterNewState() {
  switch (currentState) {
    case MOISTURE_state:
      enter_MOISTURE();
      break;

    case DISTANCE_state:
      enter_DISTANCE();
      break;

  }
}

void loop() {
  // put your main code here, to run repeatedly:
  switch (currentState) {
    case MOISTURE_state:
      service_MOISTURE();
      break;

    case DISTANCE_state:
      service_DISTANCE();
      break;

  }
   delay(100);
}

// this function sets the ring light's pixels according to the moisture level
void showMoistureLevel (uint32_t color, int num) {
    strip.clear();
   for (int i=0; i < num; i++) {
    strip.setPixelColor(i, color);
    strip.setPixelColor(23 - i, color);
   }   
    strip.show();                      
}

// the two functions below, I took them from examples code of Adafruit library. 
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for(j=0; j<256*5; j++) { // 5 cycles of all colors on wheel
    for(i=0; i< strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel(((i * 256 / strip.numPixels()) + j) & 255));
    }
    strip.show();
    delay(wait);
  }
}

uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if(WheelPos < 85) {
    return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  if(WheelPos < 170) {
    WheelPos -= 85;
    return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  WheelPos -= 170;
  return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}
