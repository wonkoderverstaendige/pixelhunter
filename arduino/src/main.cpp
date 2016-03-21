#include <Arduino.h>
#include <OneWire.h>
#include "AnalogSensor.h"
#define RAW_PIN A0
#define AMP_PIN A5
#define NO_DIGITAL 0

//AnalogSensor PD_raw("pd_raw", 33, 10, RAW_PIN, NO_DIGITAL, 1.0f);
AnalogSensor PD_amp("pd_amp", 100, 1, 121, AMP_PIN, NO_DIGITAL);

unsigned long currentMillis;

void setup() {
  Serial.begin(57600);
}

void loop() {
    currentMillis = millis();

    // ping ALL the sensors to have 'em do their thing
    //PD_raw.tick(currentMillis);
    PD_amp.tick(currentMillis);
}
