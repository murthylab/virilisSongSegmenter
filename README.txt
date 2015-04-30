This code represents a sample implementation of the automated song analysis methods initially described in the paper “Mapping the stereotyped behaviour of freely-moving fruit flies” by LaRue, KM, Clemens, J, Berman GJ, and Murthy, M (eLife, 2015).

This MATLAB code is presented in order to provide a more explicit representation of the algorithms described in the article text.

As this code is presented for the sake of methodological repeatability (and not as “Black Box” software), the use of this software is at your own risk.  The authors are not responsible for any damage that may result from errors in the software.  

Downloaders of this software are free to use, modify, or redistribute this software how they see fit, but only for non-commercial purposes and all modified versions may only be shared under the same conditions as this (see license below).  For any further questions about this code, please email Gordon Berman at gordon.berman@gmail.com.

All that being said, if any questions/concerns/bugs arise, please feel free to email me (Gordon), and I will do my absolute best to answer/resolve them.

*******

1) An example song file is included as the ‘song’ variable saved within exampleSong.mat.	
2) The set of likelihood models used in the paper is included within exampleLikelihoodModels.mat

3) To run a sample implementation, load ‘song’ into the MATLAB workspace and run 

	[maleBoutInfo,femaleBoutInfo,run_data] = segmentVirilisSong(song);

4)  Details as to the nature of the output variables listed above can be found in the comments within segmentVirilisSong.m.

5) To create a set of likelihood models, run 

	likelihoodModels = …
		find_songs_from_hand_annotations(male_songs,female_songs,overlap_songs);
  
   Here, male_songs, female_songs, and overlap_songs are each arrays of wavelet amplitudes, with each row being an example wavelet amplitudes at one point in time and each column being a different frequency channel.  

6)  Future implementations will allow for a GUI-based creation of these likelihood models.
	
*******

The MIT License (MIT)

Copyright (c) 2015 Murthy lab

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

