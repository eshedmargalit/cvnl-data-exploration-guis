function plot_beta_profile_lines__update(hemi, xyline,xypoints,Lookup,fig,S,direction)

plotobj=getappdata(fig,'guidata');
plotdata=getappdata(fig,'data');

reflayer=plotdata.reflayer;
numlh=plotdata.numlh;
numrh=plotdata.numrh;
bg_clim=plotdata.bg_clim;
ylimit=plotdata.ylimit;

numcategories=numel(plotdata.plotvals);
%%
vertidx=spherelookup_imagexy2vertidx(xyline,Lookup);

% if right hemisphere, update vertex numbers
if (strcmp(hemi,'rh'))
	vertidx = vertidx + numlh;
end

if (strcmp(direction,'r2l') || strcmp(direction,'d2u'))
	vertidx = flipud(vertidx);
end

if(min(vertidx)<=numlh && max(vertidx)>numlh)
    warning('Line segments cannot cross hemispheres!');
    return;
elseif(max(vertidx)<=numlh)
    clickhemi='lh';
    vertidx_offset=0;
else
    clickhemi='rh';
    vertidx=vertidx-numlh;
    vertidx_offset=numlh;
end

uidx=[true; vertidx(2:end)~=vertidx(1:end-1)];
vertidx=double(vertidx(uidx));
if(size(xypoints,1)>2)
    [~,pidx]=min(distance(xypoints.',xyline(uidx,:).'),[],2);
    vertidx_segments=vertidx(pidx);
else
    vertidx_segments=vertidx([1 end]);
end

%%


axlayer=plotobj.axlayer;
hbg_layer=plotobj.hbgimg;

dlayer={};
xlayer=[];
ylayer=[];
ylayer_minmax=[];
%%
if(~isempty(reflayer))
    verts=plotdata.layerverts{reflayer}(vertidx,:);
    d=[0; sqrt(sum((verts(2:end,:)-verts(1:end-1,:)).^2,2))];
    d=cumsum(d);
    for l = 1:6
        dlayer{l}=d;
    end
end
   
bg_done=false(6,1);
for plotcat_idx = 1:numcategories

    %%%% start with just beta case
    %vals=permute(mean(layerbeta(:,con1,:),2),[1 3 2]);
    
    for l = 1:6
        layerstr=sprintf('layerA%d',l);
        tagstr=sprintf('layer%dcat%d',l,plotcat_idx);    
        layertagstr=sprintf('layer%d',l);
        
        
        
        hbgimg=plotobj.hbgimg(l);
        hax=axlayer(l);

        if(isempty(reflayer))
            verts=plotdata.layerverts{l}(vertidx,:);
            d=[0; sqrt(sum((verts(2:end,:)-verts(1:end-1,:)).^2,2))];
            d=cumsum(d);
            dlayer{l}=d;
        end
        
        d=dlayer{l};
        
        

        layervals=plotdata.plotvals{plotcat_idx}(vertidx_offset+vertidx,l);
        layervals_max=plotdata.plotvals_max{plotcat_idx}(vertidx_offset+vertidx,l);
        layervals_min=plotdata.plotvals_min{plotcat_idx}(vertidx_offset+vertidx,l);
        %layererrorvals=errorvals(vertidx_offset+vertidx,l);
        layerbgvals=plotdata.plotbg(vertidx_offset+vertidx,l);
        

        do_errorpatch=~all(isnan(layervals_min));
        
        xlayer=[xlayer; d(1) d(end)];
        ylayer=[ylayer; min(layervals) max(layervals)];
        if(do_errorpatch)
            ylayer_minmax=[ylayer_minmax; min(layervals_min) max(layervals_max)];
        else
            ylayer_minmax=ylayer;
        end
        
        
        if(~isempty(hax) && ishandle(hax))
        else
            if(numel(axlayer)>=l)
                set(fig,'currentaxes',axlayer(l));
            else
                axlayer(l)=subplot(6,1,l);
                set(axlayer(l),'nextplot','add');
                set(axlayer(l),'tag',sprintf('ax_%s',layertagstr));
            end
        end
        
        if(~bg_done(l))
            bgx=linspace(d(1),d(end),1000);
            bgrespaced=interp1(d,layerbgvals,bgx,'nearest');
            bgrgb=mat2rgb(bgrespaced.','cmap','gray','clim',bg_clim);
            bgrgb=permute(bgrgb,[3 1 2]);

            if(~isempty(hbgimg) && ishandle(hbgimg))
                set(hbgimg,'xdata',d([1 end]),'ydata',[0 1],'cdata',bgrgb);
            else
                hbgimg=image(d([1 end]),[0 1],bgrgb);
                set(hbgimg,'alphadata',.75);
                set(hbgimg,'tag',sprintf('bgimg_%s',layertagstr));
            end
            bg_done(l)=true;
        end
        
        
        if(~do_errorpatch)
            hline=plotobj.hline(l,plotcat_idx);
            if(~isempty(hline) && ishandle(hline))
                set(hline,'xdata',d,'ydata',layervals);
            else
                hline=plot(d,layervals,'color',co(plotcat_idx,:));
                set(hline,'tag',sprintf('line_%s',tagstr));
            end
        else
            hpatch=plotobj.hpatch(l,plotcat_idx);
            vx=d([1:end end:-1:1]);
            vy=[layervals_min; layervals_max(end:-1:1)];
            if(~isempty(hpatch) && ishandle(hpatch))
                set(hpatch,'vertices',[vx vy],'faces',1:numel(vx));
            else
                hpatch=patch(vx,vy,'k',...
                    'facecolor',co(plotcat_idx,:),'facealpha',.25,'linestyle','none');
                set(hpatch,'tag',sprintf('patch_%s',tagstr));
            end
        end
    end
end

if(isempty(ylimit))
    yl=[min(ylayer_minmax(:,1)) max(ylayer_minmax(:,2))];
else
    yl=ylimit;
end
set(axlayer,'ylim',yl);

for l = 1:6
    set(axlayer(l),'xlim',xlayer(l,:));
    
    layertagstr=sprintf('layer%d',l);
        
    hl0=plotobj.hline0(l);
    htick=plotobj.htick(l);
    if(isempty(plotobj.htick2))
        htick2=[];
    else
        htick2=plotobj.htick2(l);
    end
    d=dlayer{l};

    xt=[d d];
    yt=[yl(1) yl(1)+.1*diff(yl)];
    
    xt=reshape([xt nan(size(d))]',[],1);
    yt=reshape(repmat([yt nan],numel(d),1)',[],1);

    if(~isempty(htick) && ishandle(htick))
        set(htick,'xdata',xt,'ydata',yt);
    else
        htick=plot(axlayer(l),xt,yt,'k');
        set(htick,'handlevisibility','off');
        set(htick,'tag',sprintf('tick_%s',layertagstr));
    end
    
    if(numel(vertidx_segments)>2)
        
    
        %if multi-segment line, draw waypoint ticks a little taller
        [~,ia,ib]=intersect(vertidx,vertidx_segments(2:end-1));
        xt=[d(ia(ib)) d(ia(ib))];
        yt=[yl(1) yl(1)+.2*diff(yl)];
        
        xt=reshape([xt nan(size(xt,1),1)]',[],1);
        yt=reshape(repmat([yt nan],numel(ib),1)',[],1);
        
        if(~isempty(htick2) && ishandle(htick2))
            set(htick2,'xdata',xt,'ydata',yt);
        else
            htick2=plot(axlayer(l),xt,yt,'k');
            set(htick2,'handlevisibility','off');
            set(htick2,'tag',sprintf('tick_%s',layertagstr));
        end
    
    end
    if(~isempty(hl0) && ishandle(hl0))
        set(hl0,'xdata',d([1 end]),'ydata',[0 0]);
    else
        hl0=plot(axlayer(l),d([1 end]),[0 0],'k');
        set(hl0,'handlevisibility','off');
        set(hl0,'tag',sprintf('line0_%s',layertagstr));
    end
    
    set(hbg_layer(l),'xdata',d([1 end]),'ydata',yl);
end

yt=get(axlayer(end),'ytick');
set(axlayer,'ytick',yt);
