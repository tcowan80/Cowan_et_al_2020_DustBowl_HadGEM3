;****************************************************************************************
;
; Fig1_GHCN_CMIP5_hwf_decadal.ncl
;
;
; This file calls in GHCN-daily data, CMIP5 data, 
; and plots figure 1 of study
;
;*****************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$WORK/ncl_scripts/append_xmgrace.ncl"
load "$WORK/ncl_scripts/random_array.ncl"
load "$WORK/ncl_scripts/get1Dindex_mult.ncl"
load "$WORK/ncl_scripts/percent_to_value.ncl"
;*****************************************************************************************

 err = NhlGetErrorObjectId() 
 
 setvalues err 
   "errLevel" : "Fatal" ; only report Fatal errors 
 end setvalues 


begin

;******************************************************************************************************************
; variables to set 
rad 	= 4.0*atan(1.0)/180. ; radians
seas 	= "JJA" ; season
met 	= "hwf" ; heat wave metric = heat wave frequency
subreg 	= "gp" ; sub-region = Great Plains
rm 	= 11  ; running mean of 11 years
runmean = "yes" ; apply running mean
anom 	= "yes" ; use anomalies not raw means

if (subreg.eq."gp") then
 lonL 	= 255 ; E
 lonR 	= 275 ; E
 lonLL 	= -105 ; W
 lonRR 	= -85 ; W
 latS 	= 30 ; N
 latN 	= 50 ; N
 region_longname = "Great Plains"
end if

; CMIP5 piControl models, with AMO and PDO values
 models_pic 	= (/"ACCESS1-0","ACCESS1-3","bcc-csm1-1","bcc-csm1-1-m","BNU-ESM",\
		"CanESM2","CESM1-BGC","CMCC-CMS","CNRM-CM5","CSIRO-Mk3-6-0",\
		"FGOALS-s2","GFDL-ESM2G","GFDL-ESM2M","inmcm4","IPSL-CM5A-LR",\
		"MIROC5","MIROC-ESM","MPI-ESM-LR","MPI-ESM-MR","MPI-ESM-P",\
		"MRI-CGCM3","NorESM1-M"/)

; historical CMIP5 models
 models_hist 	= (/"ACCESS1-0","ACCESS1-3","bcc-csm1-1","CanESM2","CCSM4",\
 		"CESM1-BGC","CMCC-CMS","CNRM-CM5","CSIRO-Mk3-6-0","GFDL-CM3",\
		"GFDL-ESM2G","GFDL-ESM2M","IPSL-CM5A-LR","IPSL-CM5A-MR","MIROC-ESM",\
		"MPI-ESM-LR","MPI-ESM-MR","MPI-ESM-P","MRI-CGCM3","NorESM1-M"/)

; size of CMIP5 arrays
 nmodels_pic 	= dimsizes(models_pic)
 nmodels_hist 	= dimsizes(models_hist)

;******************************************************************************************************************

;******************************************************************************************************************
; plotting parameters
 outfile		= "fig1_SST_composite_globe_"+met+"_"+subreg+"_GHCN"+\
		"_CMIP5_1-500yrs_"+rm+"yr_RunningAvg"
 wks 		= gsn_open_wks("eps",outfile)     ; Open a workstation and define colour map
 gsn_define_colormap(wks,"hotcolr_19lev")
 maps 		= new(nmodels_pic+1,graphic)
 maps2 		= new(nmodels_pic+1,graphic)
 poly 		= new(1,graphic) 
 boxs 		= new((/4/),graphic) 

; points for box indicating Great Plains (30-50N, 105-85W)
 ypts = (/ 30, 30, 50, 50, 30/)
 xpts = (/ -105, -85, -85, -105, -105/)
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for SSTs
 res		 		= True
 res@gsnMaximize	    	= False
 res@gsnFrame		   	= False
 res@gsnAddCyclic		= False    ; data already has cyclic point
 res@gsnTickMarksOn  		= False          ; turn off tickmark
 res@gsnLeftString 		= ""
 res@gsnCenterStringFontHeightF = 0.013
 res@gsnRightString 		= ""

 res@cnLevelSelectionMode 	= "ManualLevels"     ; set manual contour levels
 res@cnFillOn			= True     ; turn on color fill
 res@cnLinesOn 			= False    ; turn of contour lines
 res@cnLineLabelsOn 		= False
 res@cnInfoLabelOn		= False    ; turn of contour info labels
 res@cnLineLabelBackgroundColor = -1 
 res@cnLineLabelFontHeightF 	= 0.02

 res@tiMainFont   		= "helvetica" 	

 res@lbTitleString 		= "SST anomalies (~S~o~N~C)" ; bar title
 res@lbTitleFontHeightF 	= 0.015
 res@lbLabelFontHeightF 	= 0.012
 res@lbTitlePosition	 	= "Bottom"	; title location
 res@lbTitleDirection	  	= "Across"
 res@lbBoxEndCapStyle 		= "TriangleBothEnds"

 res@pmLabelBarHeightF 		= 0.075
 res@pmLabelBarWidthF 		= 0.6
 res@pmLabelBarParallelPosF 	= 1.05           ; move labelbar across
 res@pmLabelBarOrthogonalPosF 	= .27          ; move labelbar down

 res@mpOutlineOn	    	= True
 res@mpPerimOn  	    	= False
 res@mpEllipticalBoundary 	= True
 res@mpLandFillColor        	= "white"
 res@mpGridAndLimbOn	    	= False
 res@mpGridLineDashPattern  	= 2
 res@mpCenterLonF	  	= 260
 res@mpEllipticalBoundary 	= True 
 res@mpProjection 		= "Satellite"  
 res@mpCenterLatF 		= 45.         ; choose center lat
 res@mpSatelliteDistF 		= 3.0         ; choose satellite view
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for GFDL heat wave map
 res2		 		= True
 res2@gsnMaximize	    	= False
 res2@gsnFrame		   	= False
 res2@gsnTickMarksOn  		= False          ; turn off tickmark
 res2@gsnAddCyclic		= False
 res2@gsnRightString 		= ""
 res2@gsnLeftString 		= ""
 res2@gsnCenterString 		= "" 
 
 res2@mpOutlineOn	    	= True
 res2@mpPerimOn  	    	= False
 res2@mpLandFillColor        	= "white"
 res2@mpGridAndLimbOn	    	= False
 res2@mpGridLineDashPattern 	= 2
 res2@mpCenterLonF	  	= 260
 res2@mpProjection 		= "Satellite"  
 res2@mpCenterLatF  		= 45.         ; choose center lat
 res2@mpSatelliteDistF 		= 3.0         ; choose satellite view

 res2@cnLevelSelectionMode 	= "ManualLevels"     ; set manual contour levels
 res2@cnFillOn			= True     ; turn on color fill
 res2@cnLinesOn 		= True    ; turn of contour lines
 res2@cnLineLabelPlacementMode 	= "constant"    ; choose constant label method
 res2@cnLineLabelsOn 		= True
 res2@cnInfoLabelOn		= False    ; turn of contour info labels
 res2@cnLineLabelDensityF 	= 2.1
 res2@cnLineLabelBackgroundColor= -1
 res2@cnLineLabelFontHeightF 	= 0.01
 res2@cnFillColors 		= (/12,14,16,18,19,21/)
  
 res2@lbLabelBarOn 		= False
 res2@pmLabelBarHeightF 	= 0.075
 res2@pmLabelBarWidthF 		= 0.6; 0.6
 res2@pmLabelBarParallelPosF 	= 0.3; 1.05           ; move labelbar across
 res2@pmLabelBarOrthogonalPosF 	= 0.10          ; move labelbar down
 res2@lbTitleString 		= "HWF (days per summer)" ; bar title 
 res2@lbTitleFontHeightF	= 0.02; 0.015
 res2@lbTitlePosition	  	= "Bottom"			       ; title location
 res2@lbTitleDirection	  	= "Across"			      ; letter angle  
 res2@lbBoxEndCapStyle 		= "TriangleBothEnds"
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for GHCN heat wave map
 gsres             		= True
 gsres@gsnDraw     		= False            ; Don't advance the frame
 gsres@gsnFrame     		= False            ; Don't advance the frame
 gsres@gsMarkerIndex 		= 16          ; Use filled dots for markers.
 gsres@mpOutlineOn	    	= True
 gsres@mpPerimOn  	    	= False
 gsres@mpEllipticalBoundary 	= True 
 gsres@mpLandFillColor       	= "white"
 gsres@mpGridAndLimbOn	    	= False
 gsres@gsnTickMarksOn  		= False          ; turn off tickmark
 gsres@mpGridLineDashPattern  	= 2
 gsres@mpCenterLonF	  	= 260 
;******************************************************************************************************************

;******************************************************************************************************************
; resources for labelbar for HWF (panels b and c)
 lbres_colors    		= (/12,14,16,18,19,21/) ; for "WhiteYellowOrangeRed" 
 lbres  		       	= True 
 lbres@vpWidthF 	       	= 0.3   	; width
 lbres@vpHeightF	       	= 0.075   	; height
 lbres@lbPerimOn	       	= False  	  ; Turn off perimeter.
 lbres@lbOrientation	       	= "Horizontal"	; Default is vertical.
 lbres@lbLabelAlignment        	= "InteriorEdges"  ; Default is "BoxCenters".
 lbres@lbTitleString	       	= "HWF (days per summer)"
 lbres@lbMonoFillPattern       	= True		  ; Fill them all solid.
 lbres@lbLabelFontHeightF      	= 0.012		; label font height
 lbres@lbTitlePosition         	= "Bottom"	 ; title location
 lbres@lbTitleDirection        	= "Across"
 lbres@lbTitleFontHeightF      	= 0.012	           ; font height
 lbres@lbAutoManage	       	= False  	   ; we control label bar
 lbres@lbLabelStride	       	= 1	
 lbres@lbFillColors	       	= lbres_colors 	     ; Colors for boxes.
 lbres@lbBoxEndCapStyle 	= "TriangleHighEnd"
;******************************************************************************************************************

;******************************************************************************************************************
; resources for Great Plains box  
 resB		       		= True			   ; polyline mods desired
 resB@gsnDraw 			= False
 resB@gsnFrame 			= False
 resB@cnFillOn 			= False
 resB@cnInfoLabelOn   		= False			   ; turn off contour label
 resB@cnLineLabelsOn 		= False
 resB@cnFillColor 		= "black"
 resB@gsLineThicknessF 		= 2.0
;******************************************************************************************************************

;******************************************************************************************************************
; resources for Txx panel (a)
 resTS	     			= True		      ; plot mods desired
 resTS@gsnFrame 		= False		      ; don't advance frame yet      
 resTS@vpHeightF		= 0.2		      ; change aspect ratio of plot
 resTS@vpWidthF 		= 0.83	
 resTS@vpXF     		= 0.11                   ; start plot at x ndc coord 
 resTS@vpYF     		= 0.9                   ; start plot at y ndc coord 	    
 resTS@trYMinF  		= -3 ; 0		      ; min value on y-axis
 resTS@trYMaxF  		= 5 ; 28		      ; max value on y-axis
 resTS@trXMinF  		= 1910		      ; min value on y-axis
 resTS@trXMaxF  		= 2012		      ; max value on y-axis
 resTS@tmXTOn 			= False
 resTS@gsnCenterString 		= ""; "~F21~  Observed & simulated TXx anomalies" ; older version title
 resTS@gsnCenterStringOrthogonalPosF 	= 0.05
 resTS@tiXAxisString 		= "~F21~ Year"
 resTS@tiYAxisString 		= "~F21~ TXx (~S~o~N~C)"
 resTS@tiXAxisFontHeightF 	= 0.015
 resTS@tiYAxisFontHeightF 	= 0.015
 resTS@gsnLeftString 		= "~F22~ a"
 resTS@gsnLeftStringOrthogonalPosF 	= 0.02
 resTS@gsnLeftStringFontHeightF 	= 0.015
 resTS@gsnCenterStringFontHeightF 	= 0.015
;******************************************************************************************************************

;******************************************************************************************************************
; text resources for figure labels  
 txres 			= True
 txres@txFontHeightF 	= 0.012                     ; font smaller. default big  
;******************************************************************************************************************

;******************************************************************************************************************
; directories
; ghcn_dir 	= "$WORK/NatCC_wah_2019/data/GHCN/" ; files in fig1_ghcn_hw_files.tgz
; amo_pdo_dir 	= "$WORK/NatComms_HadGEM_2019/data/CMIP5/piControl/AMO_PDO/" ; files in fig1_cmip5_piControl_drivers.tgz
; cmip5_pi_dir 	= "$WORK/NatComms_HadGEM_2019/data/CMIP5/piControl/" ; files in fig1_cmip5_piControl_hwf.tgz
; cmip5_sst_dir = "$WORK/NatComms_HadGEM_2019/data/CMIP5/SST_patterns/" ; files in list_of_SST_hwf_globe_gp_over50pct_max_time_pattern_1-500yrs_11years_rm_JJA_clashes_removed_with_years_HWF_values.txt
;******************************************************************************************************************
 
;******************************************************************************************************************
; GHCN part for HWF calculations

 ghcn_fils 	= systemfunc ("ls *hw_stats_from_daily_threshold_1920-2012_"+seas+"_from_1920-2012_clim.nc") ; file paths changed
 ghcn_dimfils 	= dimsizes(ghcn_fils)
 ghcn_ave_tmax 	= new((/11,ghcn_dimfils/),float)
 ghcn_ave_tmin 	= new((/11,ghcn_dimfils/),float)
 
 ghcn_f 	= addfiles (ghcn_fils, "r")
 ListSetType (ghcn_f, "join")
 lats    	= ghcn_f[:]->lat
 lons    	= ghcn_f[:]->lon
 ghcn_time 	= ghcn_f[0]->time
 hwf_t		= ghcn_f[:]->pezHWstats(:,{1930:1940},0,0,2) ; obtain HW freq for 1930->1940
 hwf_ghcn 	= ghcn_f[:]->pezHWstats(:,:,0,0,2) ; get all HW freq from 1920->2012
 avg_hwt_t 	= dim_avg_n_Wrap(hwf_t,1) ; average HWF over 1930->1940
  
; average over the Great Plains
 lon_range 	= ispan(lonLL,lonRR,2) ; every second longitude
 lat_range 	= ispan(latS,latN,2) ; every second latitude
 station_indx 	= ind(lats.gt.latS.and.lats.lt.latN.and.lons.gt.lonLL.and.lons.lt.lonRR) ; find stations within the Great Plains region
 hwf_ghcn_f 	= hwf_ghcn(station_indx,:)
 pzlats 	= lats(station_indx) ; get latitudes of stations within the Great Plains
 pzlons 	= lons(station_indx) ; get longitudes of stations within the Great Plains
 ghcn_ave_int 	= new((/dimsizes(lat_range)*dimsizes(lon_range),dimsizes(ghcn_time)/),float) ; creat empty array (lats*lons,nyears)
 pkount 	= 0
 
; perform weighted average over Great Plains
 do aa=1,dimsizes(lon_range)-1
  do bb=1,dimsizes(lat_range)-1
   avg_indx_ghcn 		= ind(pzlats.gt.lat_range(bb-1).and.\
   				pzlats.lt.lat_range(bb).and.\
				pzlons.gt.lon_range(aa-1).and.pzlons.lt.lon_range(aa))
   if (.not.all(ismissing(avg_indx_ghcn))) then
    ghcn_int 			= hwf_ghcn_f(avg_indx_ghcn,:)   
    if (dimsizes(avg_indx_ghcn).gt.1) then
     ghcn_ave_int(pkount,:) 	= dim_avg_n_Wrap(ghcn_int,0)
    else
     ghcn_ave_int(pkount,:) 	= ghcn_int
    end if
    delete([/avg_indx_ghcn,ghcn_int/])
   else
    delete(avg_indx_ghcn)
   end if 
   pkount = pkount+1  
  end do ; aa
 end do ; bb
 
 avg_hwf_ghcn_1d  = dim_avg_n_Wrap(ghcn_ave_int,0) ; average of observed HWF over the Great Plains
;******************************************************************************************************************

;******************************************************************************************************************
;set up to plot the GHCN HW freq. 
 
 arr 			= fspan(4,20,5) ; GHCN HWF level range to be plotted
 arr_str 		= arr(::1)

 ghcn_colors 		= (/12,14,16,18,19,21/) ; colours used from palette.
 num_distinct_markers 	= dimsizes(arr)+1 ; get distinct markers to plot each station
 dum1 			= new((/num_distinct_markers/),graphic)
 lat_new 		= new((/num_distinct_markers,dimsizes(avg_hwt_t)/),float,-999) ; array of latitudes to plot
 lon_new 		= new((/num_distinct_markers,dimsizes(avg_hwt_t)/),float,-999) ; array of longitudes to plot

; loop through each distinct marker to get correct colour for plot          
 do i = 0, num_distinct_markers-1
  if (i.eq.0) then
   indexes = ind(avg_hwt_t.lt.arr(0))
  end if
  if (i.eq.num_distinct_markers-1) then
   indexes = ind(avg_hwt_t.ge.max(arr))
  end if
  if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
   indexes = ind(avg_hwt_t.ge.arr(i-1).and.avg_hwt_t.lt.arr(i))
  end if

  if (.not.any(ismissing(indexes))) then 
   npts_range = dimsizes(indexes)   ; # of points in this range.
   lat_new(i,0:npts_range-1) = lats(indexes)
   lon_new(i,0:npts_range-1) = lons(indexes)
  end if
  delete(indexes)            ; Necessary b/c "indexes" maybe different size each time
 
 end do ; i 
 
;******************************************************************************************************************
 
;******************************************************************************************************************  
; plot out figures in order of (b), (c), (a) and then (d)
do i=0,3

 
 indir = "$WORK/NatComms_HadGEM_2019/data/CMIP5/SST_patterns/" ; changed

;-------------------------------------------------------------------------------------------------------------------------
; HadISST and GHCN-D obs
 if (i.eq.0) then
  infile_sst 		= addfile("BEST_SST_"+met+"_"+"globe"+\
  			"_"+subreg+"_max_time_pattern_1-100yrs_"+rm+"years_rm_"+seas+".nc","r")
  sst 			= infile_sst->sst
  res@gsnCenterString 	= "~F22~b~F21~ Observed";  (Years 1930-1940)" ;  ("+decimalPlaces(dec_ave,1,True)+"%)"
; land sea mask
  a 			= addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
  lsm 			:= landsea_mask(a->LSMASK,sst&latitude,sst&longitude)
  new_sst 		= mask(sst,lsm.eq.1.or.lsm.eq.2,False)        ; mask out all ocean points from datas 
  copy_VarCoords(sst,new_sst)

; plot out SST
  res@vpXF            		= 0.05         
  res@vpWidthF        		= 0.3	    
  res@vpYF            		= 0.55
  res@vpHeightF       		= 0.3
  
  res@cnMinLevelValF		= -0.5	  ; set min contour level
  res@cnMaxLevelValF		= 0.5	  ; set max contour level
  res@cnLevelSpacingF		= 0.1	  ; set contour spacing  
  res@cnFixFillBleed 		= True
  res@cnGridBoundFillColor 	= -1 ; "white"
  res@lbLabelBarOn 		= True

  maps(i) 			= gsn_csm_contour_map(wks,new_sst,res)

  do iii=0, num_distinct_markers-1
   if (.not.ismissing(lat_new(iii,0)))
    gsres@gsMarkerColor      = ghcn_colors(iii)
    gsres@gsMarkerSizeF = 0.005
    dum1(iii) = gsn_add_polymarker(wks,maps(0),lon_new(iii,:),lat_new(iii,:),gsres)
   end if
  end do ; iiii

; draw Great Plains outline  
  boxi = gsn_add_polyline(wks,maps(0),xpts,ypts,resB)   
 end if ; i.eq.0
;-------------------------------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------------------------------
; GFDL-ESM2G 
 if (i.eq.1) then
  infile_sst 		:= addfile("GFDL-ESM2G_SST_"+met+"_"+"globe"+\
  			"_"+subreg+"_max_time_pattern_201-300yrs_"+rm+"years_rm_"+seas+".nc","r")
  gfdl_sst 		:= infile_sst->sst
  lat 			:= infile_sst->lat
  lon 			:= infile_sst->lon
  hw_infile 		:= addfile("usa_hw_stats_from_daily_threshold_1-500_JJA_from_1-500_clim.GFDL-ESM2G.nc","r")
  hwf 			:= hw_infile->pezHWstats({286:296},:,:,2)  ; these are years over which the HW pattern is averaged
  avg_hwf 		:= dim_avg_n_Wrap(hwf,0)
  
; plot out SST
  res@gsnCenterString 	:= "~F22~c~F21~ GFDL-ESM2G";  (Years 286-296)" 
  res@vpXF            	= 0.375         
  res@vpWidthF        	= 0.3    
  res@vpYF            	= 0.55
  res@vpHeightF       	= 0.3

  res@cnMinLevelValF	= -0.5	  ; set min contour level
  res@cnMaxLevelValF	= 0.5	  ; set max contour level
  res@cnLevelSpacingF	= 0.1	  ; set contour spacing
  res@lbLabelBarOn 	= False

  maps(i) 		= gsn_csm_contour_map(wks,gfdl_sst,res)

; plot out HWF
  res2@vpXF           	= 0.375         
  res2@vpWidthF        	= 0.55	    
  res2@vpYF            	= 1.1
  res2@vpHeightF       	= 0.00001
  
  res2@cnMinLevelValF	= 4	  ; set min contour level
  res2@cnMaxLevelValF	= 20	  ; set max contour level
  res2@cnLevelSpacingF	= 4	  ; set contour spacing 
  res2@cnLineLabelsOn 	= False
  
  lsm_a 		= landsea_mask(a->LSMASK,avg_hwf&lat,avg_hwf&lon)
  avg_hwf 		= mask(avg_hwf,lsm_a.eq.0.or.lsm_a.eq.2,False)

  maps2(3) 		= gsn_csm_contour(wks,avg_hwf,res2)
  
;  gsn_text_ndc(wks,"~F22~days per summer",0.49,0.215,txres)
;  gsn_text_ndc(wks,"~F22~0",0.365,0.187,txres)
;  gsn_text_ndc(wks,"~F22~4",0.415,0.187,txres)
;  gsn_text_ndc(wks,"~F22~8",0.465,0.187,txres)
;  gsn_text_ndc(wks,"~F22~12",0.515,0.187,txres)
;  gsn_text_ndc(wks,"~F22~16",0.56,0.187,txres)
;  gsn_text_ndc(wks,"~F22~20",0.61,0.187,txres)  
  overlay(maps(i),maps2(3))
 end if ; i.gt.1
;-------------------------------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------------------------------
; CMIP5 & BEST TXx 
 if (i.eq.2) then
  do j=0,dimsizes(models_hist)-1 ; loop through each model TXx file
   model_txx 		= models_hist(j)
   files_txx 		= systemfunc ("ls tasmax_txx_yr_"+model_txx+"_historical_r1i1p1_*")
   f_txx 		:= addfile(files_txx,"r")
   time 		:= f_txx->time
   utc_date 		:= cd_calendar(time,0)
   yyyy 		:= utc_date(:,0)
   yyyy_indx 		:= ind(yyyy.ge.1901.and.yyyy.le.2005) ; different for each model, hence why we don't use addfiles
 
   if (j.eq.0) then
    txx_avg 		= new((/dimsizes(models_hist),dimsizes(yyyy_indx)/),float)
    txx_anom_avg 	= new((/dimsizes(models_hist),dimsizes(yyyy_indx)/),float)
   end if
 
   txx 			:= f_txx->txx(yyyy_indx,{latS:latN},{lonL:lonR})
   clat 		:= cos(txx&lat*rad)
   txx_avg(j,:) 	= wgt_areaave_Wrap(txx, clat, 1.0, 0) - 273.15
   txx_avg@_FillValue 	= -1e34
   txx_anom_avg(j,:) 	= txx_avg(j,:)-avg(txx_avg(j,:))
  end do  ; j

; average over model runs 
  avg_txx_avg		= dim_avg_n_Wrap(txx_avg,0)
  avg_txx_anom_avg 	= dim_avg_n_Wrap(txx_anom_avg,0)
  
; 10pct -> 90pct 
  max_txx_avg 		= new((/dimsizes(yyyy_indx)/),float)
  min_txx_avg 		= max_txx_avg
  max_txx_anom_avg 	= max_txx_avg
  min_txx_anom_avg 	= max_txx_avg
  
  do kk=0,dimsizes(yyyy_indx)-1 
   max_txx_avg(kk) 	= percent_to_value(txx_avg(:,kk),90)
   min_txx_avg(kk) 	= percent_to_value(txx_avg(:,kk),10)
   max_txx_anom_avg(kk) = percent_to_value(txx_anom_avg(:,kk),90)
   min_txx_anom_avg(kk) = percent_to_value(txx_anom_avg(:,kk),10)	
  end do ; k  

; CMIP5 Txx bounds
  bounds 		= new((/2,dimsizes(avg_txx_avg)/),float)
  bounds(0,:) 		= max_txx_anom_avg
  bounds(1,:) 		= min_txx_anom_avg

  avg_txx_avg_rm 	= runave_Wrap(avg_txx_avg,11,0)
  bounds_rm 		= runave_n_Wrap(bounds,11,0,1)
  avg_txx_anom_avg_rm 	= runave_Wrap(avg_txx_anom_avg,11,0)

; BEST TXx 
  obs_f 		= addfile("H2_TXx_1901-2010_RegularGrid_global_3.75x2.5deg_LSmask.nc","r") 
  obs_txx 		= obs_f->Ann(:,{latS:latN},{lonL:lonR})
  lat_obs 		= obs_f->lat({latS:latN})
  lon_obs 		= obs_f->lon({lonL:lonR})
  clat_obs 		= cos(obs_txx&lat*rad)
  obs_txx_avg 		= wgt_areaave_Wrap(obs_txx,clat_obs,1.0,0)
  obs_txx_anom_avg 	= obs_txx_avg - avg(obs_txx_avg)
  year_obs 		= ispan(1901,2010,1)
  obs_txx_anom_avg!0 	= "time"
  obs_txx_anom_avg&time = year_obs

; do plot of TXx (first HadEX2)
  resTS@gsnYRefLine		= avg(obs_txx_anom_avg)  ; create a reference line   
  resTS@gsnAboveYRefLineColor 	= "red"              ; above ref line fill red
  resTS@gsnBelowYRefLineColor 	= "blue"             ; below ref line fill blue

  plot 			= gsn_csm_xy (wks,year_obs,obs_txx_anom_avg,resTS)  

  resTS@xyLineThicknessF= 3.0
  resTS@gsnCenterString = ""
  resTS@gsnLeftString 	= ""
  resTS@tiYAxisString 	= ""
  resTS@tiXAxisString 	= ""
 
; plot CMIP5 TXx ensemble
  resTS@xyLineColors 		= "brown"
  delete(resTS@gsnAboveYRefLineColor)
  years 			= ispan(1901,2005,1)
  plot_cmip5 			= gsn_csm_xy (wks,years,avg_txx_anom_avg,resTS)        ; create plot

  overlay(plot,plot_cmip5)

; plot CMIP5 TXx bounds calculated earlier
  length 		= dimsizes(years)
  xp     		= new( (/2*length/), float)
  yp    		= xp
  
  do ll=0,length-1
   yp(ll) 		= bounds(0,ll)
   xp(ll) 		= years(ll)
   xp(2*length-1-ll) 	= years(ll)
   yp(2*length-1-ll)	= bounds(1,ll)
  end do

  resTS@gsFillOpacityF 	= 0.25
  resTS@gsFillColor    	= "grey"                 ; color chosen
  plot_bounds = gsn_add_polygon(wks,plot,xp,yp,resTS)        ; create plot
 
; Shade in the 1930s
  red_res             	= True
  red_res@gsFillColor 	= "red"
  red_res@gsFillOpacityF= 0.1
  
  xbars 		= (/ 1929.8, 1929.8, 1940.2, 1940.2, 1929.8/)
  ybars 		= (/ -30, 30, 30, -30, -30/)

  box 			= gsn_add_polygon(wks,plot,xbars,ybars,red_res)

; attach legend txt to TXx plot
 gsn_text_ndc(wks,"~F21~HadEX2",0.58,.89,txres)
 gsn_text_ndc(wks,"~F21~CMIP5",0.68,.89,txres)

; attach specialised legend txt to TXx plot
; HadEX2 legend
 plres                 	=  True
 plres@gsLineThicknessF =  1.0      
 plres@gsLineColor      = "black"   
 plres@gsLineDashPattern= 5

 pmres                  =  True
 pmres@gsLineThicknessF =  1.0      
 pmres@gsLineColor      = "black"
 pmres@gsFillColor      = "red"    
 gsn_polygon_ndc(wks,(/.56,.57,.58,.56/),\
                      (/.87,.88,.87,.87/),\
                      pmres)
 
 pmres@gsFillColor 	= "blue"       
 gsn_polygon_ndc(wks,(/.58,.59,.6,.58/),\
                      (/.87,.86,.87,.87/),\
                      pmres)		       

 gsn_polyline_ndc(wks,(/.56,.57,.58,.59,.6/),\
 			(/.87,.88,.87,.86,.87/),\
			pmres)
; CMIP5 legend
 prres                  =  True
 prres@gsLineThicknessF =  3.0     
 prres@gsLineColor      = "brown"  
 gsn_polyline_ndc(wks,(/0.66,0.7/),(/.87,.87/),prres) 
 prres@gsFillOpacityF 	= 0.45
 prres@gsFillColor   	= "grey"              
 gsn_polygon_ndc(wks,(/.66,.7,.7,.66,.66/),\
                      (/.88,.88,.86,.86,.88/),\
                      prres)
end if ; i.eq.2
;-------------------------------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------------------------------
; CMIP5 AMO and PDO data 
 if (i.eq.3) then
  hwf_bin 		= new((/1500,nmodels_pic/),double)
  pdo_bin 		= new((/1500,nmodels_pic/),double)
  amo_bin 		= new((/1500,nmodels_pic/),double)

  mme_file 		= asciiread("list_of_SST_hwf_globe_gp_over50pct_1-500yrs_11years_rm_JJA.txt",-1,"string")
  mme_models 		= str_get_field(mme_file,1," ") ; list of models
  mme_yrs 		= stringtoint(str_get_field(mme_file,3," ")) ; list of model years

  mme_pdo_vals 		= new((/dimsizes(mme_yrs)/),double)
  mme_amo_vals 		= mme_pdo_vals
 
; loop through each CMIP5 piControl run, and call in AMO, PDO and HW info 
  do k=0,nmodels_pic-1
   model_pic 		:= models_pic(k)
   cvdp_file 		:= systemfunc("ls " + model_pic + "_Control.cvdp*")
   obs_file 		:= systemfunc("ls " + "HadISST.1901-2010.nc")
   hwf_file 		:= systemfunc("ls usa_hw_stats_from_daily**"+model_pic+".nc")
   cvdp_infile 		:= addfile(cvdp_file,"r")
   obs_infile 		:= addfile(obs_file,"r")
   hwf_infile 		:= addfile(hwf_file,"r")
   model_indx 		:= ind(model_pic.eq.mme_models)

; call in HW data
   hwf1 		:= hwf_infile->pezHWstats(:,{latS:latN},{lonL:lonR},2)
   lat1 		:= hwf_infile->lat({latS:latN})
   hwf_time 		:= hwf_infile->time

; area average over Great Plains 
   clat1  		:= cos(lat1*rad)
   hwf_avg 		:= wgt_areaave_Wrap(hwf1, clat1, 1.0, 0)

; call in CMIP5 and HadISST AMO and PDO time series'
   pdo 			:= cvdp_infile->pdo_timeseries_mon
   amo 			:= cvdp_infile->amo_timeseries_mon
   pdo_obs 		:= obs_infile->pdo_timeseries_mon
   amo_obs 		:= obs_infile->amo_timeseries_mon
   time1 		:= cvdp_infile->time

; Annual analysis
   amoAnn 		:= month_to_annual(amo, 1)
   pdoAnn 		:= month_to_annual(pdo, 1)
   amo_obsAnn 		:= month_to_annual(amo_obs, 1)
   pdo_obsAnn 		:= month_to_annual(pdo_obs, 1) 
   amoAnn_rm 		:= runave_Wrap(amoAnn,1,0) ; no run average
   pdoAnn_rm 		:= runave_Wrap(pdoAnn,1,0) ; no run average
   iz_amoAnn 		:= ind(.not.ismissing(amoAnn_rm))
   iz_pdoAnn 		:= ind(.not.ismissing(pdoAnn_rm))
   act_amoAnn 		:= amoAnn_rm(iz_amoAnn)
   act_pdoAnn 		:= pdoAnn_rm(iz_pdoAnn)

; JJA analysis (not used)  		
   amoJJA 		:= month_to_season (amo, "JJA")
   pdoJJA 		:= month_to_season (pdo, "JJA") 
   amo_rm 		:= runave_Wrap(amoJJA,1,0)
   pdo_rm 		:= runave_Wrap(pdoJJA,1,0)
   iz_amo 		:= ind(.not.ismissing(amo_rm))
   iz_pdo 		:= ind(.not.ismissing(pdo_rm)) 
   act_amo 		:= amo_rm(iz_amo)
   act_pdo 		:= pdo_rm(iz_pdo)

; get time and match with HW years
   utc_date1 		:= cd_calendar(act_amo&time, 0)
   year1		:= tointeger(utc_date1(:,0))    ; Convert to integer for
   month1  		:= tointeger(utc_date1(:,1))    ; use sprinti 
   day1			:= tointeger(utc_date1(:,2)) 
 
   amo_indx 		:= get1Dindex(year1,hwf_time)
   iz 			:= ind(.not.ismissing(amo_indx))
   act_indx 		:= amo_indx(iz)

; standardize AMO and PDO values
   amoAnn_vals 		:= dim_standardize_n_Wrap(act_amoAnn(act_indx),0,0)
   pdoAnn_vals 		:= dim_standardize_n_Wrap(act_pdoAnn(act_indx),0,0) 
 
   amo_obsAnn_vals 	:= dim_standardize_n_Wrap(amo_obsAnn,0,0)
   pdo_obsAnn_vals	:= dim_standardize_n_Wrap(pdo_obsAnn,0,0)

; fix AMO and PDO time attribute 
   amo_obsAnn_vals!0	= "time"
   pdo_obsAnn_vals!0	= "time" 
   amo_obsAnn_vals&time = ispan(1901,2010,1)
   pdo_obsAnn_vals&time = ispan(1901,2010,1)

; average observed AMO and PDO over the 1930s decade 
   AvgAMO_obs30s 	:= avg(amo_obsAnn_vals({1930:1939}))
   AvgPDO_obs30s	:= avg(pdo_obsAnn_vals({1930:1939}))

   hwf_vals 		:= hwf_avg(iz)

   amo_bin(0:dimsizes(amoAnn_vals)-1,k) = amoAnn_vals
   pdo_bin(0:dimsizes(amoAnn_vals)-1,k) = pdoAnn_vals
   hwf_bin(0:dimsizes(amoAnn_vals)-1,k) = hwf_vals

   if (ismissing(all(model_indx))) then
    continue
   else 
  
; get years of record-breaking HWFs 
    mme_yrs_tmp 		:= mme_yrs(model_indx)
    amo_pdo_indx 		:= get1Dindex(hwf_avg&time,mme_yrs_tmp)
    mme_pdo_vals(model_indx) 	= pdoAnn_vals(amo_pdo_indx)
    mme_amo_vals(model_indx) 	= amoAnn_vals(amo_pdo_indx)
   end if
  end do ; k

; produce HWF as a function of AMO and PDO data
  amo_1d 		= ndtooned(amo_bin)
  pdo_1d 		= ndtooned(pdo_bin)
  hwf_1d 		= ndtooned(hwf_bin)
  iz 			:= ind(.not.ismissing(amo_1d)) ; indx of missing values
 
; 1-D array of all AMO, PDO and HWF values, with missing values removed.
  amo 			:= amo_1d(iz)
  pdo 			:= pdo_1d(iz)
  hwf2 			:= hwf_1d(iz)

; mean, variance and N of HWFs
  avgX 			= avg(hwf2)
  varX 			= variance(hwf2)
  sX 			= num(hwf2) 

; calculate pdf of AMO and PDO values (using NCL function pdfx) 
  opt	     		= True
  opt@bin_min 		= -4
  opt@bin_max 		=  4
  amo_pdf 		= pdfx(amo, 32, opt)
  pdo_pdf 		= pdfx(pdo, 32, opt)

; create plot arrays
  hwf_amo_pdo 		= new((/32,32/),double)
  var_amo_pdo 		= hwf_amo_pdo
  num_amo_pdo 		= hwf_amo_pdo
  prob 			= hwf_amo_pdo
  iflag   		= False   
  tval_opt		= False       
 
; loop over the AMO and PDO pdfs and populate HWF function array with HWF means
  do jj = 0,dimsizes(pdo_pdf)-1
   do ii = 0,dimsizes(amo_pdf)-1
    indx 		:= ind(amo.ge.amo_pdf@bin_bounds(ii) \
   			.and. amo.le.amo_pdf@bin_bounds(ii+1) \
			.and. pdo.ge.pdo_pdf@bin_bounds(jj) .and. \
   			pdo.le.pdo_pdf@bin_bounds(jj+1) ) 
    if (all(ismissing(indx)))
     continue
    end if    
    hwf_amo_pdo(ii,jj) 	= dim_avg_n_Wrap(hwf2(indx),0)
    var_amo_pdo(ii,jj) 	= dim_variance(hwf2(indx))
    num_amo_pdo(ii,jj) 	= num(hwf2(indx))
    prob(ii,jj) 	= ttest(avg(hwf2(indx)),dim_variance(hwf2(indx))\
   			,num(hwf2(indx)), avgX,varX,sX, False, False)
   end do ; ii
  end do ; jj
 
; give array attributes of PDO (x) and AMO (y) 
  hwf_amo_pdo!0 	= "pdo"
  hwf_amo_pdo!1 	= "amo"
  hwf_amo_pdo&pdo 	= fspan(-4,4,32)
  hwf_amo_pdo&amo 	= fspan(-4,4,32) 
  copy_VarCoords(hwf_amo_pdo,prob)
 
; mask out non-signficant values
  hwf_amo_pdo_sig 	= where(prob.lt.0.1,hwf_amo_pdo,hwf_amo_pdo@_FillValue)
  copy_VarCoords(hwf_amo_pdo,hwf_amo_pdo_sig) 
 
; apply a 1-2-1 smoother in the horizontal and vertical
  wk_smooth121(hwf_amo_pdo(pdo|:,amo|:))
  wk_smooth121(hwf_amo_pdo(amo|:,pdo|:))

; do plot
  res@lbLabelBarOn	 = True  
  res@lbTitleString	 = "HWF (days per summer)" ; bar title
  res@lbTitlePosition	 = "Right"
  res@lbTitleAngleF	 = 90
  res@lbTitleFontHeightF = 0.012
  res@lbLabelFontHeightF = 0.012
  res@lbBoxEndCapStyle 	 = "TriangleBothEnds"
  res@lbOrientation	 = "vertical"     ; vertical label bar
  res@pmLabelBarWidthF   = 0.05
  res@pmLabelBarHeightF  = 0.3
  res@pmLabelBarParallelPosF	 = 0.5       ; move whole thing down
  res@pmLabelBarOrthogonalPosF   = -0.02	 ; move whole across
  res@vpXF		 = 0.75      
  res@vpWidthF  	 = 0.18    
  res@vpYF		 = 0.55
  res@vpHeightF 	 = 0.3    
  res@tmXBOn		 = True
  res@tmYLOn		 = True
  res@tmXBBorderOn	 = True 	     ; turn on  border
  res@tmXTBorderOn	 = True 	     ; turn on  border
  res@tmYLBorderOn	 = True 	     ; turn on  border
  res@tmYRBorderOn	 = True 	     ; turn on  border
  res@tmXBLabelFontHeightF	 = 0.012
  res@tmYLLabelFontHeightF	 = 0.012
  res@tmXBPrecision	 = 1
  res@tmYLPrecision	 = 1
  res@cnLinesOn 	 = False    ; no contour lines
  res@cnLineLabelsOn	 = False    ; no contour line labels
  res@cnInfoLabelOn	 = False 
  res@tiXAxisString	 = "PDO normalized"
  res@tiYAxisString	 = "AMO normalized"
  res@tiXAxisFontHeightF = 0.012
  res@tiYAxisFontHeightF = 0.012
  res@gsnCenterString		= "~F22~d~F21~ CMIP5";  HWF"
  res@cnLevelSelectionMode	= "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels		 = (/4,5,6,7,8,9/)
  res@cnFillColors	 = (/12,13,14,15,16,18,20/)
  res@trXMinF		 = -3.0
  res@trXMaxF		 = 3.0
  res@trYMinF		 = -3.0
  res@trYMaxF		 = 3.0 
  plot_amo_pdo		 = gsn_csm_contour (wks, hwf_amo_pdo(pdo|:,amo|:), res)
  
; add HadISST line
  polyres1			= True
  polyres1@gsLineDashPattern 	= 2
 
  dumL1   		= gsn_add_polyline(wks,plot_amo_pdo,\
 			(/AvgPDO_obs30s,AvgPDO_obs30s/),(/-1000,1000/),polyres1) 
  dumL2   		= gsn_add_polyline(wks,plot_amo_pdo,\
 			(/-1000,1000/),(/AvgAMO_obs30s,AvgAMO_obs30s/),polyres1) 
    
; label HadISST line
  txres@txFontHeightF 	= 0.01
  plot_hadisst		= gsn_add_text(wks,plot_amo_pdo,"~F21~HadISST",1.6,1.3,txres)
 end if ; i.eq.3
end do ; i 
;******************************************************************************************************************
levels=ispan(4,20,4)
gsn_labelbar_ndc (wks,dimsizes(lbres_colors),""+levels,0.215,0.25,lbres) 

draw(wks)
delete(wks)
system("convert -density 144x144 -trim " + outfile + ".eps " + outfile + ".png")
end
