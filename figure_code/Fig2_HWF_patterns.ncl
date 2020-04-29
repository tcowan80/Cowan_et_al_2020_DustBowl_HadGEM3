;****************************************************************************************
;
; Fig2_HWF_patterns.ncl
;
;
; This script plots the 1930-37 averaged heatwave frequencies
; for the HadGEM3 simulations (HIST, ATL, PAC, bare soil) and GHCN-D stations
;
;****************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$WORK/ncl_scripts/tickmarks.ncl" ; for LambertEqualArea plots
;****************************************************************************************

 err = NhlGetErrorObjectId() 
 
 setvalues err 
   "errLevel" : "Fatal" ; only report Fatal errors 
 end setvalues 

begin

;******************************************************************************************************************
; variables to set
mets 		= (/"hwf","hwaa"/)
nmets 		= dimsizes(mets)
met_names 	= oneDtostring(mets)
met_names 	= str_sub_str(met_names, ",", "_")
years 		= ispan(1930,1937,1) ; for the 1930s
nyears 		= dimsizes(years)

dset 		= "HadGEM3"
type 		= "hottest"
runs 		= (/"GHCN","xmvq_hA-cP","xmvq_hP-cA","xmvp","xmvqu_r69_soil","xmvqt_r69_soil"/) ; ,"xmvqs_r69_soil"/)
nruns 		= dimsizes(runs)
regi 		= "gp"
top_rankd 	= years(dimsizes(years)-1) - years(0) + 1; 8
getseas 	= 2 ; JJA
gettype 	= 2 ; hottest HW

stat_test 	= "mwu"
ks_test 	= "no"

if (regi.eq."gp") then
 latS 	= 30
 latN 	= 50
 lonL 	= 255
 lonR 	= 275  
 lonLL 	= -105
 lonRR 	= -85
 latXS 	= 46   ; user specified for extra masking of Lake Superior
 latXN 	= 48.5 
 lonXW 	= 269  
 lonXE 	= 276  
 latYS 	= 41
 latYN 	= 42   
 lonYW 	= 277
 lonYE 	= 280	
end if

;******************************************************************************************************************

;******************************************************************************************************************
; plotting parameters
 outfile 	= "fig2_"+dset+"_hwf_usa_JJA_"+years(0)+\
 		"-"+years(dimsizes(years)-1)+"_"+stat_test+"_soil_extent"
 wks 		= gsn_open_wks("eps", outfile)     ; Open a workstation and
 gsn_define_colormap(wks,"WhiteYellowOrangeRed") ; new colour map
 maps 		= new((/(nruns)/),graphic)
 plots 		= new((/nruns/),graphic)
 boxs 		= new((/4/),graphic)   
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for gridded figures
 res			= True
 res@gsnDraw		= False
 res@gsnFrame		= False
 res@gsnAddCyclic      	= False    ; data already has cyclic point

 res@mpProjection	= "LambertEqualArea"
 res@mpGridAndLimbOn	= True
 res@mpGridLatSpacingF 	= 10
 res@mpLimitMode	= "LatLon"
 res@mpMinLatF	 	= 25.
 res@mpMaxLatF	 	= 50.
 res@mpMinLonF	 	= 253
 res@mpMaxLonF	 	= 290
 res@mpCenterLonF 	= 260
 res@mpCenterLatF	= 40.0
 
 res@mpGridLineDashPattern 	= 2  
 res@mpGridLineThicknessF 	= 0.25
 res@mpOutlineOn 	= True
	
 res@cnFillColors    	= (/2,25,48,71,94,117,140,163,186,209,255/) ; for "WhiteYellowOrangeRed" 11 colours	
 res@cnFillOn		= True     ; turn on color fill
 res@cnLinesOn  	= False    ; turn of contour lines
 res@cnLevelSelectionMode 	= "ManualLevels"     ; set manual contour levels
 res@cnLineLabelsOn 	= False
 res@cnMinLevelValF	= 3	     ; set min contour level
 res@cnMaxLevelValF	= 30	     ; set max contour level
 res@cnLevelSpacingF	= 3	     ; set contour space
 
 res@pmTickMarkDisplayMode  	= "Always"  	 ; turn on fancy tickmarks
 res@pmLabelBarOrthogonalPosF 	= .17	      ; move whole thing down
 
 res@gsnMaximize 	= False
 res@gsnLeftString 	= ""
 res@gsnRightString	= ""
 res@gsnCenterStringFontHeightF = 0.038
 
 res@lbLabelBarOn 	= False
 res@lbLabelFontHeightF = 0.02
 res@lbTitlePosition 	= "Bottom"

 res@tmYRLabelsOn 	= False   
 res@tmYLLabelsOn 	= False
 res@tmXBLabelsOn 	= False
 res@tmYRLabelsOn 	= False
 res@tmXTLabelsOn 	= False
 res@tmYLOn 		= False
 res@tmXBOn 		= False
 res@tmYROn 		= False
 res@tmXTOn		= False  

 res@tiYAxisString 	= ""
;****************************************************************************************************************** 
  
;******************************************************************************************************************
; map resources for lat/lon labels 
 tmres 				= True
 tmres@tmYRValues 		= ispan(20,60,10)
 tmres@tmYRLabelFontHeightF 	= 0.025
 tmres@tmXBValues 		= ispan(-135,-30,15)
 tmres@tmXBLabelFontHeightF 	= 0.025
 tmres@YUseLeft 		= False
;******************************************************************************************************************

;******************************************************************************************************************
; resources for box
 ypts = (/ 30, 30, 50, 50, 30/)
 xpts = (/ -105, -85, -85, -105, -105/)
;******************************************************************************************************************

;******************************************************************************************************************
; resources for labelbar
 colors    	= (/2,25,48,71,94,117,140,163,186,209,255/) ; for "WhiteYellowOrangeRed" 
 lbres  		       = True 
 lbres@vpWidthF 	       = 0.05   	; width
 lbres@vpHeightF	       = 0.35   	; height
 lbres@lbPerimOn	       = False  	  ; Turn off perimeter.
 lbres@lbOrientation	       = "Vertical"	; Default is vertical.
 lbres@lbLabelAlignment        = "InteriorEdges"  ; Default is "BoxCenters".
 lbres@lbTitleString	       = "days/summer"
 lbres@lbMonoFillPattern       = True		  ; Fill them all solid.
 lbres@lbLabelFontHeightF      = 0.01		; label font height
 lbres@lbTitlePosition         = "Right"	 ; title location
 lbres@lbTitleDirection        = "Across"
 lbres@lbTitleAngleF	       = 90
 lbres@lbTitleFontHeightF      = 0.01	           ; font height
 lbres@lbAutoManage	       = False  	   ; we control label bar
 lbres@lbLabelStride	       = 1	
 lbres@lbFillColors	       = colors 	     ; Colors for boxes.
;******************************************************************************************************************

;******************************************************************************************************************
; resources for GHCN-D (circle) plot
 gsres               		= True
 gsres@gsMarkerIndex 		= 16          ; Use filled dots for markers.
 gsres@gsnDraw     		= False            ; Don't advance the frame
 gsres@gsnFrame     		= False            ; Don't advance the frame
 gsres@mpOutlineOn		= True
 gsres@mpPerimOn  		= True
 gsres@mpEllipticalBoundary 	= True 
 gsres@mpLandFillColor 		= "white"
 gsres@mpGridAndLimbOn		= True
 gsres@gsnTickMarksOn  		= False          ; turn off tickmark
 gsres@mpGridLineDashPattern  	= 2
 gsres@mpCenterLonF	  	= 260  
 gsres@mpOutlineDrawOrder	= "PreDraw"
 gsres@mpGeophysicalLineColor	= "black"
;******************************************************************************************************************

;******************************************************************************************************************
; resources for stippling
 opt 			= True 
 opt@gsnShadeFillType 	= "pattern" ; pattern fill 
 opt@gsnShadeHigh 	= 17 
;******************************************************************************************************************

;******************************************************************************************************************
; resources for bare soil plots
 resB		       = True			   ; polyline mods desired
 resB@gsnDraw	       = False
 resB@gsnFrame         = False
 resB@cnFillOn         = False
 resB@cnInfoLabelOn    = False  		    ; turn off contour label
 resB@cnLineLabelsOn   = False
 resB@cnLinesOn        = False   ; turn of contour lines  
 resB@cnMinLevelValF   = 0		 ; set min contour level
 resB@cnMaxLevelValF   = 1		 ; set max contour level
 resB@cnLevelSpacingF  = 0.01		    ; set contour spacing
 resB@cnMonoFillScale  = True
 resB@cnFillScaleF     = 0.5 
;******************************************************************************************************************** 

;********************************************************************************************************************
; resources for vegetation contours
 sres 			= True
 sres@gsLineColor	= "black"		      ; color of lines
 sres@gsLineThicknessF 	= 0.5			    ; thickness of lines
 sres@gsnDraw 		= False
 sres@gsnFrame 		= False
 sres@cnFillOn 		= False
 sres@cnInfoLabelOn   	= False                      ; turn off contour label
 sres@cnLineLabelsOn 	= True
 sres@cnLinesOn 	= True  ; turn of contour lines  
 sres@cnMinLevelValF	= 16. 	      ; set min contour level
 sres@cnMaxLevelValF	= 20.		; set max contour level
 sres@cnLevelSpacingF	= 2.	      ; set contour spacing 
 sres@cnLineLabelInterval 	= 1             ; default = 2 
 sres@cnLineLabelPlacementMode 	= "constant"    ; choose constant label method
 sres@cnLineLabelFontHeightF 	= 0.02
;******************************************************************************************************************

;******************************************************************************************************************
; loop through each `run` (GHCN-D, ATL, PAC, HIST, 30% soil, 50% soil)
var1 = mets(0)

kk = 0 ; for plot counter

 do j=0,nruns-1
  
  run = runs(j)

;------------------------------------------------------------------------------------------------------------------
; GHCN-D 
  if (run.eq."GHCN") then
   ghcn_fils 		= systemfunc ("ls *hw_stats_from_daily_threshold_1920-1955_JJA_from_1920-2012_clim.nc") ; file paths
   ghcn_dimfils 	= dimsizes(ghcn_fils)
   ghcn_ave_tmax 	= new((/top_rankd,ghcn_dimfils/),float)
   ghcn_ave_tmin 	= new((/top_rankd,ghcn_dimfils/),float)
   ghcn_f 		= addfiles (ghcn_fils, "r")
   ListSetType (ghcn_f, "join")
   lats    		= ghcn_f[:]->lat
   lons    		= ghcn_f[:]->lon
   ghcn_time 		= ghcn_f[0]->time
   hw_years		= years
   hwf_t		= ghcn_f[:]->pezHWstats(:,{hw_years},0,0,2)
   hwf_ghcn 		= ghcn_f[:]->pezHWstats(:,:,0,0,2)
   avg_hwf_ghcn 	= dim_avg_n_Wrap(hwf_t,1)  ; average over the Dust bowl period

   arr 			= fspan(3,30,10) ; used for HWF levels
   arr_str 		= arr(::1)

   ghcn_colors    = (/2,25,48,71,94,117,140,163,186,209,255/) ; for "WhiteYellowOrangeRed" 
   labels = new(dimsizes(arr)+1,string) 
   num_distinct_markers = dimsizes(arr)+1 
   dum1 = new((/num_distinct_markers/),graphic)

   lat_new = new((/num_distinct_markers,dimsizes(avg_hwf_ghcn)/),float,-999)
   lon_new = new((/num_distinct_markers,dimsizes(avg_hwf_ghcn)/),float,-999)

; Group the points according to which range they fall in. At the
; same time, create the label that is used later in the legend.
;       
   do ii=0, num_distinct_markers-1
    if (ii.eq.0) then
     indexes 	= ind(avg_hwf_ghcn.lt.arr(0))
     labels(ii) = "x < " + arr(0)
    end if
    if (ii.eq.num_distinct_markers-1) then
     indexes 	= ind(avg_hwf_ghcn.ge.max(arr))
     labels(ii) = "x >= " + max(arr)
    end if
    if (ii.gt.0.and.ii.lt.num_distinct_markers-1) then       
     indexes 	= ind(avg_hwf_ghcn.ge.arr(ii-1).and.avg_hwf_ghcn.lt.arr(ii))
     labels(ii) = arr(ii-1) + " <= x < " + arr(ii)
    end if 
 
    if (.not.any(ismissing(indexes))) then 
     npts_range 		= dimsizes(indexes)   ; # of points in this range.
     lat_new(ii,0:npts_range-1) = lats(indexes)
     lon_new(ii,0:npts_range-1) = lons(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" maybe a different size next time. 
   end do ; ii 
 
   res@gsnCenterString 	= "GHCN-D"     ; add panel title
   maps(j)		= gsn_csm_map(wks,res)
 
   do iii=0, num_distinct_markers-1 
    if (.not.ismissing(lat_new(iii,0)))
     gsres@gsMarkerColor      	= ghcn_colors(iii)
     gsres@gsMarkerSizeF 	= 0.005
     dum1(iii) 			= gsn_add_polymarker(wks,maps(j),lon_new(iii,:),lat_new(iii,:),gsres)
    end if
   end do ; iiii

  
   boxs 	= gsn_add_polyline(wks,maps(j),xpts,ypts,resB) ; add Great Plains outline    
   maps(j) 	= add_map_tickmarks(wks,maps(j),tmres)  


 end if
;------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------
;land sea mask
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
;------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------
; HadGEM3 HIST runs 
 if (run.eq."xmvp") then
  infiles 	:= systemfunc ("ls hw_dates_usa_JF-SON_1916-1955_clim.xmvp**from_ref_xmvp_ens.nc") ; file paths
  infile 	:= addfiles(infiles,"r")
  ListSetType (infile, "join")        ; concatenate (=default)
  
  hwf 		:= infile[:]->$var1$(:,getseas,gettype,{hw_years},:,:)
  avg_hwf 	:= dim_avg_n_Wrap(hwf,(/0,1/))
  max_hist_hwf  := dim_max_n_Wrap(dim_avg_n_Wrap(hwf,0),0)

  lsm_a 	:= landsea_mask(a->LSMASK,avg_hwf&lat,avg_hwf&lon)
  avg_hwf_masked := mask(avg_hwf,lsm_a.eq.0.or.lsm_a.eq.2,False)        ; mask out all ocean points from data
  copy_VarCoords(avg_hwf, avg_hwf_masked)

  res@gsnCenterString = "HIST" ; "ALL~B~HIST"
  
; add in bare soil amounts for the HIST runs for 1930
  basefile 	= addfile("qrparm.HYDE31_2.nc","r")
  base 		= basefile->wbfl(5,7,:,:)
  base_pct 	= base*100
  copy_VarCoords(base,base_pct)

  lat_idx 		= ind(base_pct&latitude.lt.30 .or. base_pct&latitude.gt.44)     ; insert soil amounts over Great Plains
  lon_idx 		= ind(base_pct&longitude.lt.259 .or. base_pct&longitude.gt.280) ; insert soil amounts over Great Plains
  base_pct(:,lon_idx) 	= base_pct@_FillValue
  base_pct(lat_idx,:) 	= base_pct@_FillValue

; mask values over Lakes region
  lat3d 	:= conform(avg_hwf_masked, avg_hwf&lat, 0)
  lon3d 	:= conform(avg_hwf_masked, avg_hwf&lon, 1)
  		
  avg_hwf_masked 	= where(lat3d.ge.latXS .and. lat3d.le.latXN .and. \
  	       		lon3d.ge.lonXW .and. lon3d.le.lonXE \
  	       		,avg_hwf_masked@_FillValue, avg_hwf_masked)
  avg_hwf_masked 	= where(lat3d.ge.latYS .and. lat3d.le.latYN .and. \
                 	lon3d.ge.lonYW .and. lon3d.le.lonYE \
                 	,avg_hwf_masked@_FillValue, avg_hwf_masked)

  maps(j)	= gsn_csm_contour_map_overlay(wks,avg_hwf_masked,base_pct,res,sres) 
  maps(j) 	= add_map_tickmarks(wks,maps(j),tmres)
  
 end if ; (run.eq."xmvp")
;------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------
; HadGEM3 ATL runs 
 if (run.eq."xmvq_hA-cP") then
  infiles 	:= systemfunc ("ls hw_dates_usa_JF-SON_1916-1955_clim.**xmvq**hA-cP**from_ref_xmvp_ens.nc") ; file paths
  infile 	:= addfiles(infiles,"r")
  ListSetType (infile, "join")        ; concatenate (=default)
  
  hwf 		:= infile[:]->$var1$(:,getseas,gettype,{hw_years},:,:)
  
  dim4d 	:= dimsizes(hwf) ; used for Mann-Whitney U Test
 
  avg_hwf 	:= dim_avg_n_Wrap(hwf,(/0,1/))
  tmp_hwf_atl 	:= reshape(hwf,(/dim4d(0)*top_rankd,dim4d(2),dim4d(3)/))

  lsm_a 	= landsea_mask(a->LSMASK,avg_hwf&lat,avg_hwf&lon)
  avg_hwf_masked := mask(avg_hwf,lsm_a.eq.0.or.lsm_a.eq.2,False)        ; mask out all ocean points from data
  copy_VarCoords(avg_hwf, avg_hwf_masked)
  avg_hwf_atl 	:= avg_hwf_masked ; stored later for MWU test
  
  res@gsnCenterString 	:= "ATL~B~HIST~N~" 

; mask values over Lakes region 
  lat3d 	:= conform(avg_hwf_masked, avg_hwf&lat, 0)
  lon3d 	:= conform(avg_hwf_masked, avg_hwf&lon, 1)
  
  avg_hwf_masked 	= where(lat3d.ge.latXS .and. lat3d.le.latXN .and. \
  	      		 lon3d.ge.lonXW .and. lon3d.le.lonXE \
  	       		,avg_hwf_masked@_FillValue, avg_hwf_masked)
  avg_hwf_masked 	= where(lat3d.ge.latYS .and. lat3d.le.latYN .and. \
                	 lon3d.ge.lonYW .and. lon3d.le.lonYE \
                 	,avg_hwf_masked@_FillValue, avg_hwf_masked)				 
  ATL 		= avg_hwf_masked ; stored for later
  
  maps(j)	= gsn_csm_contour_map(wks,avg_hwf_masked,res)
  maps(j) 	= add_map_tickmarks(wks,maps(j),tmres)
   
 end if ; (run.eq."xmvq_hA-cP")
;------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------
; HadGEM3 PAC runs 
 if (run.eq."xmvq_hP-cA") then
  infiles 	:= systemfunc ("ls hw_dates_usa_JF-SON_1916-1955_clim.**xmvq**hP-cA**from_ref_xmvp_ens.nc") ; file paths
  infile 	:= addfiles(infiles,"r")
  ListSetType (infile, "join")        ; concatenate (=default)
  
  hwf 		:= infile[:]->$var1$(:,getseas,gettype,{hw_years},:,:)
  lat		:= infile[0]->lat
  lon		:= infile[0]->lon
  avg_hwf 	:= dim_avg_n_Wrap(hwf,(/0,1/))
  
  tmp_hwf_pac 	:= reshape(hwf,(/dim4d(0)*top_rankd,dim4d(2),dim4d(3)/))
  
  lsm_a 	:= landsea_mask(a->LSMASK,avg_hwf&lat,avg_hwf&lon)
  avg_hwf_masked := mask(avg_hwf,lsm_a.eq.0.or.lsm_a.eq.2,False)        ; mask out all ocean points from data
  copy_VarCoords(avg_hwf, avg_hwf_masked)
  avg_hwf_pac 	:= avg_hwf_masked
 
  res@gsnCenterString 	:= "PAC~B~HIST~N~" ; , ATL~B~CLIM"
  
; mask values over Lakes region
  lat3d 	:= conform(avg_hwf_masked, lat, 0)
  lon3d 	:= conform(avg_hwf_masked, lon, 1)
  
  avg_hwf_masked 	= where(lat3d.ge.latXS .and. lat3d.le.latXN .and. \
  	       		lon3d.ge.lonXW .and. lon3d.le.lonXE \
  	       		,avg_hwf_masked@_FillValue, avg_hwf_masked)
  avg_hwf_masked 	= where(lat3d.ge.latYS .and. lat3d.le.latYN .and. \
  	       		lon3d.ge.lonYW .and. lon3d.le.lonYE \
  	       		,avg_hwf_masked@_FillValue, avg_hwf_masked)			       
  PAC 		= avg_hwf_masked

  maps(j)	= gsn_csm_contour_map(wks,avg_hwf_masked,res) 
  maps(j) 	= add_map_tickmarks(wks,maps(j),tmres)

 end if ; (run.eq."xmvq_hA-cP")
;------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------
; HadGEM3 bare soil runs 
 if (run.eq."xmvqv_r69_soil".or.run.eq."xmvqs_r69_soil".or.run.eq."xmvqt_r69_soil".or.run.eq."xmvqu_r69_soil") then
  infiles 	:= systemfunc ("ls hw_dates_usa_JF-SON_1916-1940_clim."+run+"_from_ref_xmvp_ens.nc") ; file paths  hw_dates_usa_JF-SON_1916-1940_clim.xmvqu_r69_soil.nc
  infile 	:= addfile(infiles,"r")

  hwf 		:= infile->$var1$(getseas,gettype,{hw_years},:,:)
  avg_hwf 	:= dim_avg_n_Wrap(hwf,0)
  
  lsm_a 	:= landsea_mask(a->LSMASK,avg_hwf&lat,avg_hwf&lon)
  avg_hwf_masked := mask(avg_hwf,lsm_a.eq.0.or.lsm_a.eq.2,False)        ; mask out all ocean points from data
  copy_VarCoords(avg_hwf, avg_hwf_masked)

  lat3d 	:= conform(avg_hwf_masked, lat, 0)
  lon3d 	:= conform(avg_hwf_masked, lon, 1)
 
  if (run.eq."xmvqt_r69_soil") then
   res@gsnCenterString 	= "50% soil" ; 
   gt_hist_hwf50 	= where(avg_hwf_masked.gt.max_hist_hwf,1,0)
   copy_VarCoords(avg_hwf,gt_hist_hwf50)
   gt_hist_hwf50 	= where(lat3d.ge.latXS .and. lat3d.le.latXN .and. \
  	       		lon3d.ge.lonXW .and. lon3d.le.lonXE \
  	       		,gt_hist_hwf50@_FillValue, gt_hist_hwf50)
   gt_hist_hwf50 	= where(lat3d.ge.latYS .and. lat3d.le.latYN .and. \
                 	lon3d.ge.lonYW .and. lon3d.le.lonYE \
                 	,gt_hist_hwf50@_FillValue, gt_hist_hwf50)
  end if
  if (run.eq."xmvqu_r69_soil") then
   res@gsnCenterString = "30% soil" ; 
   gt_hist_hwf30 	= where(avg_hwf_masked.gt.max_hist_hwf,1,0)
   copy_VarCoords(avg_hwf,gt_hist_hwf30)
  end if
 
; mask values over Lakes region
 		
  avg_hwf_masked 	= where(lat3d.ge.latXS .and. lat3d.le.latXN .and. \
 	      		 lon3d.ge.lonXW .and. lon3d.le.lonXE \
 	      		 ,avg_hwf_masked@_FillValue, avg_hwf_masked)
  avg_hwf_masked 	= where(lat3d.ge.latYS .and. lat3d.le.latYN .and. \
 	       		lon3d.ge.lonYW .and. lon3d.le.lonYE \
 	       		,avg_hwf_masked@_FillValue, avg_hwf_masked)			       

  maps(j)	= gsn_csm_contour_map(wks,avg_hwf_masked,res) 
  maps(j) 	= add_map_tickmarks(wks,maps(j),tmres)

 end if ; (run.eq."soil")
;------------------------------------------------------------------------------------------------------------------

end do ; j
;******************************************************************************************************************

;******************************************************************************************************************
; Mann-Whitney U test testing ATL and PAC runs 
; as Mfile exists, this will skip over this part
if (stat_test.eq."mwu") then

 Mfile = "M_array_"+dset+"_"+met_names+"_top_rankd_"+top_rankd+\
 	"_"+type+"_usa_JJA_from_daily_95pctl_"+years(0)+"-"+\
	years(dimsizes(years)-1)+"_"+stat_test+".nc"

 if (.not.fileexists(Mfile)) then

  dimsX 	= dimsizes(avg_hwf_atl)
  nlatX 	= dimsX(0)
  nlonX 	= dimsX(1)  

  U_array 	= new((/nlatX,nlonX/),float,-999)
  copy_VarCoords(avg_hwf_atl,U_array)

  do ilatX = 0, nlatX-1
   do ilonX = 0, nlonX-1

    x1 		:= tmp_hwf_atl(:,ilatX,ilonX)
    x2 		:= tmp_hwf_pac(:,ilatX,ilonX)
  
    arry 	:= new((/dimsizes(x1),7/),float)
 
    arry(:,0) 	= x1(:)
    arry(:,1) 	= x2(:)
    arry(:,2) 	= 0
    arry(:,3) 	= 1
    sort_no 	:= array_append_record(arry(:,0),arry(:,1),0)
    sort_zero 	:= array_append_record(arry(:,2),arry(:,3),0)
    ip 		:= dim_pqsort_n(sort_no,1,0) ; + 1
  
    arry2 	:= sort_no(ip)
    zero 	:= sort_zero(ip) 
       
    n1 		:= dimsizes(x1)
    n2 		:= dimsizes(x2)

    sort_rnk 	:= new(dimsizes(arry2),float,arry2@_FillValue) 

    asciiwrite ("foo.txt" , sprintf("%9.3f", arry2 ))
    rnk 	:= systemfunc("awk -f ranking_f.awk foo.txt") 
    sort_rnk 	:= stringtofloat(rnk)
   
    y1 		:= where(zero.eq.0,sort_rnk,0)
    y2 		:= where(zero.eq.1,sort_rnk,0)
  
    R1 		:= sum(y1)
    R2 		:= sum(y2)
    
    U1 		:= R1 - (0.5*(n1*(n1+1)))
    U2 		:= R2 - (0.5*(n2*(n2+1)))
 
    UU 		:= min (array_append_record(U1,U2,0))
  
    mU 		:= (n1*n2)*0.5
    tauU 	:= ((n1*n2*(n1+n2+1))/12)^0.5
    zU 		:= (UU - mU)/tauU
  
    U_array(ilatX,ilonX) = zU
   end do
  end do  

  fout 			= addfile(Mfile,"c")
  fout->U_array_hwf 	= U_array
  U_array_hwf 		= U_array
  delete(U_array)

 else
 
  fout 			= addfile(Mfile,"r")
  U_array_hwf 		= fout->U_array_hwf
 
 end if

 UU_hwf 		= where(abs(U_array_hwf).ge.1.96,1,0)  ; 1.645 for 90%,  1.96 for 95%
 UU_hwf 		= mask(UU_hwf,lsm_a.eq.0.or.lsm_a.eq.2,False)	  ; mask out all ocean points from data
 copy_VarCoords(U_array_hwf,UU_hwf)
 UU_hwf_ATL 		= where(ATL.gt.PAC,1,0)
 UU_hwf_PAC 		= where(PAC.gt.ATL,1,0)
 
 UU_hwf_a 		= UU_hwf*UU_hwf_ATL
 UU_hwf_p 		= UU_hwf*UU_hwf_PAC
 copy_VarCoords(U_array_hwf,UU_hwf_a)
 copy_VarCoords(U_array_hwf,UU_hwf_p)

; add significance to ATL and PAC maps 
 plots(0) = gsn_csm_contour(wks,UU_hwf_a,resB)
 plots(1) = gsn_csm_contour(wks,UU_hwf_p,resB) ; contours are at 95,100 
 plots(2) = gsn_csm_contour(wks,gt_hist_hwf30,resB)
 plots(3) = gsn_csm_contour(wks,gt_hist_hwf50,resB)
 plots(0) = gsn_contour_shade(plots(0),0,0.5,opt) ; pattern fill all areas 
 plots(1) = gsn_contour_shade(plots(1),0,0.5,opt) ; pattern fill all areas 
 plots(2) = gsn_contour_shade(plots(2),0,0.5,opt) ; pattern fill all areas
 plots(3) = gsn_contour_shade(plots(3),0,0.5,opt) ; pattern fill all areas 
 
 overlay(maps(1),plots(0))
 overlay(maps(2),plots(1))
 overlay(maps(4),plots(2))
 overlay(maps(5),plots(3))


end if ; if (stat_test.eq."mwu") then
;******************************************************************************************************************

;******************************************************************************************************************
; create panel

resP		     	= True		       ; modify the panel plot
resP@gsnFrame	      	= False		       ; don't advance panel plot
resP@gsnPanelMainString = "~F21~ Summer heatwave frequency composite (1930-1937)" ; Heat wave frequency (HWF)"
resP@lbLabelFontHeightF = 0.01
resP@lbTitleFontHeightF = 0.01
resP@gsnPanelTop   	= 0.65 ; 0.95		 ; add space at bottom ; turn off ususally
resP@gsnPanelBottom  	= 0.1 ; 0.55		  ; add space at bottom ; turn off ususally
resP@gsnPanelLeft 	= 0.0
resP@gsnPanelRight 	= 0.93

resP@gsnMaximise 			= True
resP@gsnPanelFigureStrings		= (/"~F22~a","~F22~b","~F22~c","~F22~d","~F22~e","~F22~f"/) ; add strings to panel
resP@gsnPanelFigureStringsPerimOn 	= False
resP@amJust   				= "TopLeft"
resP@gsnPanelFigureStringsFontHeightF 	= 0.01
resP@gsnPanelYWhiteSpacePercent 	= 5
gsn_panel(wks,maps,(/2,3/),resP)

; add labelbar to panel
levels=ispan(3,30,3)
gsn_labelbar_ndc (wks,dimsizes(colors),""+levels,0.94,0.55,lbres) 

frame(wks)
delete(wks)
system("convert -density 144x144 -trim " + outfile + ".eps " + outfile + ".png")

end 


