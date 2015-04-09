function out = rectify(x,val)

     out = x;
     out(x<val) = val;