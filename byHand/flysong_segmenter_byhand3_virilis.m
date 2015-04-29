%function flysong_segmenter_byhand3(file)
%function flysong_segmenter_byhand3(data,Fs)
%
%file is the .daq output filename of array_take
%data is a matrix containing the data from daqread()
%Fs is the sampling rate
%
%popupmenu on the left selects the channel number
%pan with < and >, zoom with + and -
%add multiple pulses by clicking on each and then pressing the return key (PULSE_MODE=1)
%add a pulse by clicking on the peak and trough (PULSE_MODE=2)
%add a sine song by clicking on the beginning and end
%delete removes just those currently displayed
%save creates a .mat file with _byhand appended to filename
%  if workspace data passed in, file is workspace_byhand.mat
%
%ver 0.2:
%  now loads in old byhand.mat files if they exist for further editing
%  supports passing in workspace variables
%  pulses delineated by either peak and trough, or just peak
%  can now listen to data too
%
%ver 0.3:
%  now resizes gracefully
%  added PULSE_MODE
%  added keyboard shortcuts (p = add pulse song, s = add sine song, etc)
%  added confirmation dialog for delete of N>10 items
%  toggle y-axis scale option
%  added sonogram
%
%to convert PULSE_MODE=1 _byhand.mat files to PULSE_MODE=2, rename them to
% _old.mat, load them, and then PULSE=[PULSE PULSE(:,2)+0.001]; and then
% save() without _old;

function flysong_segmenter_byhand3_virilis(varargin)

global RAW IDXMP IDXFP PAN ZOOM
global CHANNEL FILE DATA MPULSE FPULSE OVERLAP PULSE_MODE YSCALE NFFT
global FS NARGIN H

PULSE_MODE=1;

IDXMP=[];
IDXFP=[];
IDXO=[];
M=[];
TOGGLE=[];
PAN=0;  % ms
ZOOM=100;  % ms
SHIFT=max(RAW)-min(RAW);
EDIT=0;
STEP_SIZE=1;
DELETE_BUTTON=[];
CHANNEL=2;
NARGIN=nargin;
NFFT=2^9;

if(NARGIN==1)
  VARARGOUT=[];
  if(strcmp(varargin{1}(end-3:end),'.daq'))
    FILE=varargin{1}(1:end-4);
  else
    FILE=varargin{1};
  end

  if(exist([FILE '_byhand.mat'],'file'))
    load([FILE '_byhand.mat']);
  else
    MPULSE=[];
    FPULSE=[];
    OVERLAP=[];
  end

  dinfo=daqread(FILE,'info');
  NCHAN=length(dinfo.ObjInfo.Channel);
  FS=dinfo.ObjInfo.SampleRate;
  RAW=daqread(FILE,'Channel',CHANNEL);
else
  MPULSE=[];
  FPULSE=[];
  OVERLAP=[];
 
  DATA=varargin{1};
  NCHAN=size(DATA,2);
  FS=varargin{2};
  RAW=DATA(:,CHANNEL);
end

YSCALE=max(max(RAW));
if(PAN>length(RAW)/FS*1000) PAN=0; end
if((PAN+ZOOM)>(length(RAW)/FS*1000)) ZOOM=(length(RAW)/FS*1000)-PAN; end

figure;
tmp=get(gcf,'position');
set(gcf,'position',[0 0 1.5*tmp(3) 1.5*tmp(4)]);
set(gcf,'menubar','none','ResizeFcn',@resizeFcn,'WindowKeyPressFcn',@windowkeypressFcn);

H=uipanel();
uicontrol('parent',H,'style','popupmenu','value',CHANNEL,...
   'string',1:NCHAN, ...
   'callback', @changechannel_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','<','tooltipstring','pan left', ...
   'callback', @panleft_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','^','tooltipstring','zoom in', ...
   'callback', @zoomin_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','v','tooltipstring','zoom out', ...
   'callback', @zoomout_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','>','tooltipstring','pan right', ...
   'callback', @panright_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(y)scale','tooltipstring','toggle y-scale', ...
   'callback', @yscale_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(f)req','tooltipstring','increase frequency resolution', ...
   'callback', @nfftup_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(t)ime','tooltipstring','increase temporal resolution', ...
   'callback', @nfftdown_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(m)male','tooltipstring','add male pulse song', ...
   'callback', @addmalepulse_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(n)female','tooltipstring','add female pulse song', ...
   'callback', @addfemalepulse_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(b)overlap','tooltipstring','add overlap', ...
   'callback', @addoverlap_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(d)elete','tooltipstring','delete displayed song', ...
   'callback', @delete_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','(l)isten','tooltipstring','listen to displayed recording', ...
   'callback', @listen_callback);
uicontrol('parent',H,'style','pushbutton',...
   'string','save','tooltipstring','save segmentation to disk', ...
   'callback', @save_callback);

update;


function resizeFcn(src,evt)

global H

tmp=get(gcf,'position');
foo=get(H,'children');

for(i=1:length(foo))
  switch(get(foo(i),'string'))
    case('<')
      set(foo(i),'position',[80,tmp(4)-30,20,20]);
    case('^')
      set(foo(i),'position',[100,tmp(4)-30,20,20]);
    case('v')
      set(foo(i),'position',[120,tmp(4)-30,20,20]);
    case('>')
      set(foo(i),'position',[140,tmp(4)-30,20,20]);
    case('(y)scale')
      set(foo(i),'position',[160,tmp(4)-30,50,20]);
    case('(f)req')
      set(foo(i),'position',[210,tmp(4)-30,40,20]);
    case('(t)ime')
      set(foo(i),'position',[250,tmp(4)-30,40,20]);
    case('(m)male')
      set(foo(i),'position',[290,tmp(4)-30,50,20]);
    case('(n)female')
      set(foo(i),'position',[340,tmp(4)-30,50,20]);
      case('(b)overlap')
      set(foo(i),'position',[390,tmp(4)-30,50,20]);
    case('(d)elete')
      set(foo(i),'position',[440,tmp(4)-30,50,20]);
    case('(l)isten')
      set(foo(i),'position',[490,tmp(4)-30,50,20]);
    case('save')
      set(foo(i),'position',[540,tmp(4)-30,40,20]);
    otherwise
      set(foo(i),'position',[20,tmp(4)-30,50,20]);
  end
end


function windowkeypressFcn(src,evt)

switch(evt.Key)
  case('leftarrow')
    panleft_callback;
  case('uparrow')
    zoomin_callback;
  case('downarrow')
    zoomout_callback;
  case('rightarrow')
    panright_callback;
  case('y')
    yscale_callback;
  case('f')
    nfftup_callback;
  case('t')
    nfftdown_callback;
  case('m')
    addmalepulse_callback;
  case('n')
    addfemalepulse_callback;
    case('b')
    addoverlap_callback;
  case('d')
    delete_callback;
  case('l')
    listen_callback;
end



function changechannel_callback(hObject,eventdata)

global FILE DATA RAW CHANNEL PAN ZOOM NARGIN

CHANNEL=get(hObject,'value');
if(NARGIN==1)
  RAW=daqread(FILE,'Channel',CHANNEL);
else
  RAW=DATA(:,CHANNEL);
end
update;



function panleft_callback(hObject,eventdata)

global PAN ZOOM;
PAN=max(0,PAN-ZOOM/2);
update;



function zoomin_callback(hObject,eventdata)

global PAN ZOOM;

if(ZOOM<10)  return;  end;
ZOOM=ZOOM/2;
PAN=PAN+ZOOM/2;
update;



function zoomout_callback(hObject,eventdata)

global PAN ZOOM RAW FS;

PAN=max(0,PAN-ZOOM/2);
ZOOM=ZOOM*2;
if((PAN+ZOOM)>(length(RAW)/FS*1000))
  ZOOM=(length(RAW)/FS*1000)-PAN;
end
update;



function panright_callback(hObject,eventdata)

global PAN ZOOM RAW FS;

PAN=min(length(RAW)/FS*1000-ZOOM,PAN+ZOOM/2);
update;



function addmalepulse_callback(hObject,eventdata)

global CHANNEL MPULSE PULSE_MODE;

% if(PULSE_MODE==1)
%   tmpM=ginput;
%   tmpM2=size(tmpM,1);
%   MPULSE(end+1:end+tmpM2,:)=[repmat(CHANNEL,tmpM2,1) tmpM(:,1)];
% else
  tmpM=ginput(2);
  MPULSE(end+1,:)=[CHANNEL tmpM(:,1)'];
% end
update;

function addfemalepulse_callback(hObject,eventdata)

global CHANNEL FPULSE PULSE_MODE;

if(PULSE_MODE==1)
  tmpF=ginput;
  tmpF2=size(tmpF,1);
  FPULSE(end+1:end+tmpF2,:)=[repmat(CHANNEL,tmpF2,1) tmpF(:,1)];
else
  tmpF=ginput(2);
  FPULSE(end+1,:)=[CHANNEL tmpF(:,1)'];
end
update;

function addoverlap_callback(hObject,eventdata)

global CHANNEL OVERLAP PULSE_MODE;

if(PULSE_MODE==1)
  tmpF=ginput;
  tmpF2=size(tmpF,1);
  OVERLAP(end+1:end+tmpF2,:)=[repmat(CHANNEL,tmpF2,1) tmpF(:,1)];
else
  tmpF=ginput(2);
  OVERLAP(end+1,:)=[CHANNEL tmpF(:,1)'];
end
update;



function delete_callback(hObject,eventdata)

global MPULSE FPULSE OVERLAP IDXMP IDXFP IDXO;

tmpp=setdiff(1:size(MPULSE,1),IDXMP);
tmps=setdiff(1:size(FPULSE,1),IDXFP);
tmpo=setdiff(1:size(OVERLAP,1),IDXO);
foo='yes';
bar=length(IDXMP)+length(IDXFP)+length(IDXO);
if(bar>10)
   foo=questdlg(['are you sure you want to delete these ' num2str(bar) ' items?'],...
       '','yes','no','no');
end
if(strcmp(foo,'yes'))
  MPULSE=MPULSE(tmpp,:);
  FPULSE=FPULSE(tmps,:);
  OVERLAP=OVERLAP(tmpo,:);
end
update;



function listen_callback(hObject,eventdata)

global RAW PAN ZOOM FS;

sound(RAW((1+ceil(PAN/1000*FS)):floor((PAN+ZOOM)/1000*FS)),FS);



function save_callback(hObject,eventdata)

global FILE MPULSE FPULSE OVERLAP NARGIN VARARGOUT;

if(NARGIN==1)
  save([FILE '_byhand.mat'],'MPULSE','FPULSE','OVERLAP');
else
  save(['workspace_byhand.mat'],'MPULSE','FPULSE','OVERLAP');
end


function yscale_callback(hObject,eventdata)

global YSCALE

YSCALE=-YSCALE;
update;


function nfftup_callback(hObject,eventdata)

global NFFT

NFFT=NFFT*2;
update;


function nfftdown_callback(hObject,eventdata)

global NFFT

NFFT=NFFT/2;
update;


function update

global RAW IDXMP IDXFP IDXO PAN ZOOM 
global CHANNEL FILE MPULSE FPULSE OVERLAP PULSE_MODE YSCALE NFFT
global FS

foo2=(1+ceil(PAN/1000*FS)):floor((PAN+ZOOM)/1000*FS);
foo=RAW(foo2);

subplot(2,1,1);  cla;  hold on;
if(length(foo)>NFFT)
  [s,f,t,p]=spectrogram(foo',NFFT,[],[],FS,'yaxis');
  fidx=find(f>=25 & f<=2500);
  surf((t+foo2(1)./FS).*1000,f(fidx),log10(abs(p(fidx,:))),'EdgeColor','none');
  colormap(flipud(gray));
  axis tight;
  ylabel('frequency (Hz)');
end

subplot(2,1,2);  cla;  hold on;

IDXMP=[];
if(~isempty(MPULSE))
%   if(PULSE_MODE==1)
%     IDXMP=find((MPULSE(:,1)==CHANNEL) & ...
%            (((MPULSE(:,2)>=PAN) & (MPULSE(:,2)<=(PAN+ZOOM)))));
%   else
    IDXMP=find((MPULSE(:,1)==CHANNEL) & ...
           (((MPULSE(:,2)>=PAN) & (MPULSE(:,2)<=(PAN+ZOOM))) | ...
            ((MPULSE(:,3)>=PAN) & (MPULSE(:,3)<=(PAN+ZOOM)))));
%   end
end

IDXFP=[];
if(~isempty(FPULSE))
  if(PULSE_MODE==1)
    IDXFP=find((FPULSE(:,1)==CHANNEL) & ...
           (((FPULSE(:,2)>=PAN) & (FPULSE(:,2)<=(PAN+ZOOM)))));
  else
    IDXFP=find((FPULSE(:,1)==CHANNEL) & ...
           (((FPULSE(:,2)>=PAN) & (FPULSE(:,2)<=(PAN+ZOOM))) | ...
            ((FPULSE(:,3)>=PAN) & (FPULSE(:,3)<=(PAN+ZOOM)))));
  end
end

IDXO=[];
if(~isempty(OVERLAP))
  if(PULSE_MODE==1)
    IDXO=find((OVERLAP(:,1)==CHANNEL) & ...
           (((OVERLAP(:,2)>=PAN) & (OVERLAP(:,2)<=(PAN+ZOOM)))));
  else
    IDXO=find((OVERLAP(:,1)==CHANNEL) & ...
           (((OVERLAP(:,2)>=PAN) & (OVERLAP(:,2)<=(PAN+ZOOM))) | ...
            ((OVERLAP(:,3)>=PAN) & (OVERLAP(:,3)<=(PAN+ZOOM)))));
  end
end

for(i=1:length(IDXMP))
    if isempty(IDXMP)==1;
        MPULSE=[];
    else
%   if(PULSE_MODE==1)
%     plot([MPULSE(IDXMP(i),2) MPULSE(IDXMP(i),2)],[min(foo) max(foo)],...
%           'b-','linewidth',3);
%   else
    patch([MPULSE(IDXMP(i),2) MPULSE(IDXMP(i),2) MPULSE(IDXMP(i),3) MPULSE(IDXMP(i),3)],...
          [min(foo)  max(foo)  max(foo)  min(foo)],...
          'b','EdgeColor','b');
%   end
    end
end

for(i=1:length(IDXFP))
  if(PULSE_MODE==1)
    plot([FPULSE(IDXFP(i),2) FPULSE(IDXFP(i),2)],[min(foo) max(foo)],...
          'r-','linewidth',3);
  else
    patch([FPULSE(IDXFP(i),2) FPULSE(IDXFP(i),2) FPULSE(IDXFP(i),3) FPULSE(IDXFP(i),3)],...
          [min(foo)  max(foo)  max(foo)  min(foo)],...
          'r','EdgeColor','r');
  end
end

for(i=1:length(IDXO))
  if(PULSE_MODE==1)
    plot([OVERLAP(IDXO(i),2) OVERLAP(IDXO(i),2)],[min(foo) max(foo)],...
          'g-','linewidth',3);
  else
    patch([OVERLAP(IDXO(i),2) OVERLAP(IDXO(i),2) OVERLAP(IDXO(i),3) OVERLAP(IDXO(i),3)],...
          [min(foo)  max(foo)  max(foo)  min(foo)],...
          'g-','EdgeColor','g');
  end
end

plot(foo2./FS.*1000,foo,'k');

axis tight;
if(YSCALE<0)
    v=axis;
    axis([foo2(1)./FS.*1000 foo2(end)./FS.*1000 v(3) v(4)]);
else
    axis([foo2(1)./FS.*1000 foo2(end)./FS.*1000 -YSCALE YSCALE]);
end
xlabel('time (ms)');

v=axis;
subplot(2,1,1);
vv=axis;
axis([v(1) v(2) vv(3) vv(4)]);
