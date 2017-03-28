
Sound rope
v 1.0.1
--
>author Stan le Punk
>see other Processing work on https://github.com/StanLepunK
>2017-2017


This code is based on Minin Library
>see https://github.com/ddf/Minim

Global
--
void set_sound(int bands) ;
>set your sound, the max of bands can be analyze is '512'

audio_buffer(MIX) ;
>choice your audio source 'MIX', 'RIGHT', 'LEFT'



Spectrum
--
set_spectrum(int bands) ;
>set your sound, the max of bands can be analyze is '256'

spectrum_scale(float value)
> set the scale of represention of sound spectrum values.



Band
--
float band(int target) ;
>return the value of the band

float band(AudioBuffer fftData, int target) ;
>return the value of the band

float band(AudioBuffer fftData, int target, float scale) ;
>return the value of the band

int num_bands() ;
>return the num of active band in the spectrum









Beat
--
float get_beat_alert(int target) ;
>return the beat value alert of the target band


void set_beat(float... threshold) ;
>Add threshold to detect the beat, the value is set by block, if you have two value, the first is for the left part of spectrum, and the other is for the right part
>If you have more band than value pass, the algorithm restart from the first value ; the value are in relation with the spectrum_scale value





