
Sound rope
v 1.0.4
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
void set_spectrum(int num, float scale, float scale)
>set your sound, the max of bands can be analyze is '256'
>set the scale of represention of sound spectrum values, this value is used to detect the beat too.





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









TIME TRACK
--
void set_time_track(float threshold, float time_to_reset);
>set the sensibility of your time_track
>threshold is use to comapre this value with the spectrum sum, by default this value is '0.5'
>float time_to_reset is the threshold to reset the time, each frame when there is no sound detected, the '0.1' is add to the silence timer. By default the 'time_to_reset' is '1.0' when the this value is more than, the tracker is reset to '0'

float get_time_track();
>return the time in seconde elapse since the last silence









Beat
--
void set_beat(float... threshold) ;
>Add threshold to detect the beat, the value is set by block, if you have two value, the first is for the left part of spectrum, and the other is for the right part
>If you have more band than value pass, the algorithm restart from the first value ; the value are in relation with the spectrum_scale value


boolean beat_is() ;
>return true if there is beat

boolean beat_is(int target_beat_range) ;
>return true if there is beat on this specific beat range


float get_beat_alert(int target) ;
>return the beat value alert of the target band


boolean beat_band_is(int target_band) ;
>return true is there is a beat on this band

int get_beat_in(int which_beat) 
>return the entry band of this beat

int get_beat_out(int which_beat) {
>return the exit band of this beat

int beat_num()
>return the quantity of beat analyze





