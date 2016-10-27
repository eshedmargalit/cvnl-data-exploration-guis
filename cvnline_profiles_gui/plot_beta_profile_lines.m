function fig = plot_beta_profile_lines(hemi, xyline,xypoints,plotmetric,Lookup,fig,S,direction)

%Lookup, bgdata, 

%bgdata=meanepi;
%bgdata=meanhom;

%betaopts=fillstruct(subject, numlh, numrh, layerbeta, layerse,...
%   layerbeta_even, layerse_even, layerbeta_odd, layerse_odd, do_evenodd, 
%   Lookup)
%    TR, layers, layermean_hrf,categorynames,catcolors);

dumpstruct(S);

valstruct=struct('data',zeros(numlh+numrh,1),'numlh',numlh,'numrh',numrh);

vertidx=spherelookup_imagexy2vertidx(xyline,Lookup);

% if right hemisphere, update vertex numbers
if (strcmp(hemi,'rh'))
	vertidx = vertidx + numlh;
end
	
%if going right to left, flip order of vertices
if (strcmp(direction,'r2l') || strcmp(direction,'d2u'))
	vertidx=flipud(vertidx);
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

fprintf('\n');
fprintf('Line profile vertices\n');
for i = 1:numel(vertidx_segments)
    fprintf('%s vertex %10d %12s | lhrh vertex %10d\n',clickhemi,vertidx_segments(i),'',vertidx_segments(i)+vertidx_offset);
end
fprintf('\n');
    
%%
plotmetric_name=plotmetric;

if(~isequal(errormode,'evenodd') && ~isequal(errormode,'none'))
    switch(plotmetric)
        case 'betanorm'
            errormode='senorm';
        case 'betanormL1'
            errormode='senormL1';
        case 'betaraw'
            errormode='seraw';
        case {'betamean','mean'}
            errormode='none';
    end
end

%%
firidx=[];
sz=size(layerbeta);
if(size(layerbeta,4)>1)
    layerbeta=permute(layerbeta,[1 2 4 3]);
    layerbeta=reshape(layerbeta,[],size(layerbeta,3));
    [layerbeta,firidx]=max(layerbeta,[],2);
    layerbeta=reshape(layerbeta,sz(1:3));
end

if(size(layerse,4)>1 && ~isempty(firidx))
    layerse=permute(layerse,[1 2 4 3]);
    layerse=reshape(layerse,[],size(layerse,3));
    layerse=layerse(sub2ind(size(layerse),(1:size(layerse,1))',firidx));
    layerse=reshape(layerse,sz(1:3));
end
%%
%bg_clim=[nanmin(meanhom(:)) nanmax(meanhom(:))];
bg_clim=prctile(bgdata(:),[0,99]);


if(isempty(catcolors))
    if(numel(categorynames)<=7)
        catcolors=get(0,'DefaultAxesColorOrder');
    else
        catcolors=jet(numel(categorynames));
    end
else
    co=catcolors;
end

if(isempty(fig) || ~ishandle(fig))
    fig=figure;
end

%figureprep([100 100 1000 1500]);
axlayer=[];
hbg_layer=[];
hline=[];
hpatch=[];
htick=[];
htick2=[];
hline0=[];
plotvals={};
plotvals_min={};
plotvals_max={};
plotbg=squeeze(bgdata);

dlayer={};
xlayer=[];
ylayer=[];
ylayer_minmax=[];


do_evenodd=isequal(errormode,'evenodd') && ...
    ~isempty(layerbeta_even) && ~isempty(layerbeta_odd);

layerverts={};
for l = 1:6
    surftype=sprintf('layerA%d',reflayer);
    surf=cvnreadsurface(subject,clickhemi,surftype,surfsuffix);
    layerverts{l}=surf.vertices;
end


do_1cat=false;
for plotcat_idx = 1:numel(categorynames)
    con1=categories{plotcat_idx};
    
    vals=valstruct.data;
    vals_even=[];
    vals_odd=[];
        
    switch(plotmetric)
        case 'betaraw'
            vals=compute_glm_metric(layerbeta,meanepi,con1,[],plotmetric,tdim);
            if(do_evenodd)
                vals_even=compute_glm_metric(layerbeta_even,meanepi,con1,[],plotmetric,tdim);
                vals_odd=compute_glm_metric(layerbeta_odd,meanepi,con1,[],plotmetric,tdim);
            end
        case 'betamean'
            vals=compute_glm_metric(layerbeta,[],[],[],'beta',tdim);
            if(do_evenodd)
                vals_even=compute_glm_metric(layerbeta_even,[],[],[],'beta',tdim);
                vals_odd=compute_glm_metric(layerbeta_odd,[],[],[],'beta',tdim);
            end
        case 'mean'
            vals=meanepi;
            errormode='none';
            do_1cat=true;
        case 'R2'
            vals=layerbeta;
            errormode='none';
            do_1cat=true;
        otherwise
            vals=compute_glm_metric(layerbeta,layerse,con1,[],plotmetric,tdim);
            if(do_evenodd)
                vals_even=compute_glm_metric(layerbeta_even,layerse_even,con1,[],plotmetric,tdim);
                vals_odd=compute_glm_metric(layerbeta_odd,layerse_odd,con1,[],plotmetric,tdim);
            end
    end

    errorvals=zeros(size(vals));
    vals_min=zeros(size(vals));
    vals_max=zeros(size(vals));
    switch(errormode)
        case 'se'
            errorvals=sqrt(mean(layerse(:,con1,:,:).^2,tdim));
            vals_min=vals-errorvals;
            vals_max=vals+errorvals;
        case 'senorm'
            errorvals=sqrt(mean(layerse(:,con1,:,:).^2,tdim));
            errorvals=bsxfun(@rdivide,errorvals,sqrt(sum(layerbeta.^2,tdim)));
            vals_min=vals-errorvals;
            vals_max=vals+errorvals;
        case 'senormL1'
            errorvals=sqrt(mean(layerse(:,con1,:,:).^2,tdim));
            errorvals=bsxfun(@rdivide,errorvals,sum(abs(layerbeta),tdim));
            vals_min=vals-errorvals;
            vals_max=vals+errorvals;
        case 'seraw'
            errorvals=sqrt(mean(bsxfun(@times,layerse(:,con1,:,:),meanepi/100).^2,tdim));
            vals_min=vals-errorvals;
            vals_max=vals+errorvals;
        case 'secommon'
            errorvals=compute_glm_metric([],layerse,[],[],'secommon',tdim);
            vals_min=vals-errorvals;
            vals_max=vals+errorvals;            
        case 'evenodd'
            errorvals=abs(vals_even-vals_odd)/2;
            vals_min=min(vals_even,vals_odd,tdim);
            vals_max=max(vals_even,vals_odd,tdim);
        case 'none'
            vals_min=nan(size(vals));
            vals_max=nan(size(vals));
            %vals_min=vals-errorvals;
            %vals_max=vals+errorvals;

    end
    vals=squeeze(vals);
    vals_min=squeeze(vals_min);
    vals_max=squeeze(vals_max);
    bgvals=squeeze(bgdata);
    
    plotvals{plotcat_idx}=vals;
    plotvals_min{plotcat_idx}=vals_min;
    plotvals_max{plotcat_idx}=vals_max;
    
    if(~isempty(reflayer))
        verts=layerverts{reflayer}(vertidx,:);
        d=[0; sqrt(sum((verts(2:end,:)-verts(1:end-1,:)).^2,2))];
        d=cumsum(d);
        for l = 1:6
            dlayer{l}=d;
        end
    end
    
    for l = 1:6
        layerstr=sprintf('layer%d',l);
        tagstr=sprintf('layer%dcat%d',l,plotcat_idx);    
        layertagstr=sprintf('layer%d',l);
        
        if(isempty(reflayer))
            verts=layerverts{l}(vertidx,:);
            d=[0; sqrt(sum((verts(2:end,:)-verts(1:end-1,:)).^2,2))];
            d=cumsum(d);
            dlayer{l}=d;
        else

        end
        
        d=dlayer{l};
        

        layervals=vals(vertidx_offset+vertidx,l);
        layervals_max=vals_max(vertidx_offset+vertidx,l);
        layervals_min=vals_min(vertidx_offset+vertidx,l);
        layererrorvals=errorvals(vertidx_offset+vertidx,l);
        layerbgvals=bgvals(vertidx_offset+vertidx,l);
        

        do_errorpatch=~all(isnan(layervals_min));
        
        xlayer=[xlayer; d(1) d(end)];
        ylayer=[ylayer; min(layervals) max(layervals)];
        if(do_errorpatch)
            ylayer_minmax=[ylayer_minmax; min(layervals_min) max(layervals_max)];
        else
            ylayer_minmax=ylayer;
        end
        
        if(numel(axlayer)>=l)
            set(fig,'currentaxes',axlayer(l));
        else
            axlayer(l)=subplot(6,1,l);
            set(axlayer(l),'nextplot','add');
            set(axlayer(l),'tag',sprintf('ax_%s',layertagstr));

            bgx=linspace(d(1),d(end),1000);
            bgrespaced=interp1(d,layerbgvals,bgx,'nearest');
            bgrgb=mat2rgb(bgrespaced.','cmap','gray','clim',bg_clim);
            bgrgb=permute(bgrgb,[3 1 2]);
            hbg_layer(l)=image(d([1 end]),[0 1],bgrgb);
            set(hbg_layer(l),'tag',sprintf('bgimg_%s',layertagstr));
            %legend(categorynames);
        end

        %h=plot(d,vals);
        %delete(h);
        %plot(d,vals,'s','markersize',3);
        if(~do_errorpatch)
            hl=plot(d,layervals,'color',co(plotcat_idx,:));
            set(hl,'tag',sprintf('line_%s',tagstr));
            hline(l,plotcat_idx)=hl;
        else
            hp=patch(d([1:end end:-1:1]),[layervals_min; layervals_max(end:-1:1)],'k',...
                'facecolor',co(plotcat_idx,:),'facealpha',.25,'linestyle','none');
            set(hp,'tag',sprintf('line_%s',tagstr));
            hpatch(l,plotcat_idx)=hp;
        end

        set(axlayer(l),'xlim',xlayer(l,:));
        grid on;
        ylabel(cleantext(layerstr));
    end
    if(do_1cat)
        break;
    end
end

xlabel(axlayer(end),'surface distance (mm)');
if(isempty(plottitle))
    plottitle=cleantext(plotmetric_name);
end

suptitle(plottitle);

%set(axlayer,'xlim',[0 max(xlayer)]);
%yl=[min(ylayer(:,1)) max(ylayer(:,2))];
%yl=[-1 1];



if(isempty(ylimit))
    yl=[min(ylayer_minmax(:,1)) max(ylayer_minmax(:,2))];
else
    yl=ylimit;
end

set(axlayer,'ylim',yl);
set(hbg_layer,'ydata',yl);
set(hbg_layer,'alphadata',.75);

for l = 1:6
    layertagstr=sprintf('layer%d',l);
    d=dlayer{l};
    xt=[d d nan(size(d))];
    yt=repmat([yl(1) yl(1)+.1*diff(yl) nan],numel(d),1);
   
    ht=plot(axlayer(l),reshape(xt',[],1),reshape(yt',[],1),'k');
    
    %ht=plot(axlayer(l),xt,yt,'k');
    set(ht,'handlevisibility','off');
    set(ht,'tag',sprintf('tick_%s',layertagstr));
    htick(l)=ht;
    if(numel(vertidx_segments)>2)
        %if multi-segment line, draw waypoint ticks a little taller
        [~,ia,ib]=intersect(vertidx,vertidx_segments(2:end-1));
        xt=[d(ia(ib)) d(ia(ib)) nan(size(ib))];
        yt=repmat([yl(1) yl(1)+.2*diff(yl) nan],numel(ib),1);
        ht=plot(axlayer(l),reshape(xt',[],1),reshape(yt',[],1),'k');
        %ht=plot(axlayer(l),[d(ia(ib)) d(ia(ib)); nan nan],[yl(1) yl(1)+.2*diff(yl)],'k');
        set(ht,'handlevisibility','off');
        set(ht,'tag',sprintf('tick2_%s',layertagstr));
        htick2(l)=ht;
    else
        ht=plot(axlayer(l),nan,nan,'k');
        set(ht,'handlevisibility','off');
        set(ht,'tag',sprintf('tick2_%s',layertagstr));
        htick2(l)=ht;
    end
    hl0=plot(axlayer(l),d([1 end]),[0 0],'k');
    set(hl0,'handlevisibility','off');
    set(hl0,'tag',sprintf('line0_%s',layertagstr));
    hline0(l)=hl0;
end
fullscreen v;

yt=get(axlayer(end),'ytick');
set(axlayer,'ytick',yt);

if(do_1cat)
    hleg=[];
else
    hleg=legend(categorynames);
    p=get(hleg,'position');
    set(hleg,'position',[0 1-p(4) p(3) p(4)]);
end

hbgimg=hbg_layer;

plotobj=fillstruct(fig,axlayer,hbgimg,hline,hpatch,htick,htick2,hline0);
plotdata=fillstruct(plotvals,plotvals_min,plotvals_max,plotbg,layerverts,numlh,numrh,bg_clim,ylimit,reflayer);
setappdata(fig,'guidata',plotobj);
setappdata(fig,'data',plotdata);


