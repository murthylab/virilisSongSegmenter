function CC = largeBWConnComp(x,minLength)

    CC = bwconncomp(x);
    lengths = zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        lengths(i) = length(CC.PixelIdxList{i});
    end
    
    idx = lengths >= minLength;
    
    CC.NumObjects = sum(idx);
    CC.PixelIdxList = CC.PixelIdxList(idx);