function BoutPauses  = findBoutPauses(bouts)

%get pauses between bouts

shifted_bout_starts = circshift(bouts.Start,-1);
bouts_pauses = shifted_bout_starts - bouts.Stop; 
bouts_pauses  = bouts_pauses(1:end-1);

BoutPauses  = bouts_pauses;
