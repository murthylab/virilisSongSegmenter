for i=1:94;
if ~isempty(FIPIW{i});
if length(FIPIW{i})>10;
FIPIWmedian(i)=median(FIPIW{i}); else FIPIWmedian(i)=NaN;
end; else FIPIWmedian(i)=NaN;
end
end
for i=1:94;
if ~isempty(MIBIW{i})
bouts=MIBIW{i}(find(~isnan(MIBIW{i})));
if length(bouts)>10;
MIBIWmedian(i)=median(bouts); else MIBIWmedian(i)=NaN;
end
else MIBIWmedian(i)=NaN;
end
end