;****************************************************************************************
;
; Fig4_ATL_PAC_prcp_ef.ncl
;
;
; This script plots the 1930-37 averaged Apr-May precipitation, evap. fraction
; and 850hPa moisture flux for HadGEM3 ATL and PAC simulations.
; The script also plots the climatological precip. and EF for the HadGEM3 bare soil runs.
;
;****************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$WORK/ncl_scripts/tickmarks.ncl" ; for LambertEqualArea plots
;******************************************************************************************************************

 err = NhlGetErrorObjectId() 
 
 setvalues err 
   "errLevel" : "Fatal" ; only report Fatal errors 
 end setvalues

begin

;******************************************************************************************************************
; variables to set
setfileoption("nc","SuppressClose",False)
years 	= ispan(1930,1937,1) ; for the 1930s
vars 	= (/"prcp","ef"/)  ; precipitation and evap. fraction (EF)
nvars 	= dimsizes(vars)

nBoot 	= 10000   
month_list	= ispan(1,12,1)
reg 	= "sgp"
rad	= 4.0*atan(1.0)/180.0 ; radians

xseas = (/"April","May"/)
xseas_names = oneDtostring(xseas)
xseas_names = str_sub_str(xseas_names, ",", "_")
stat_test = "boot" ; bootstrapping

if (reg.eq."sgp") then
 lonL = 255; -105
 lonR = 275; -85
 lonLL = -105
 lonRR = -85
 latS = 30
 latN = 40 
 region_longname = "southern Great Plains"
end if  

;******************************************************************************************************************
; plotting parameters
 outfile = "fig4_HadGEM3_prcp_ef_"+years(0)+"-"+years(dimsizes(years)-1)+"_"+stat_test+"_"+xseas_names
 wks = gsn_open_wks("eps",outfile)         ; Open a workstation and
 gsn_define_colormap(wks,"BlueDarkRed18") ; define a different colormap.
 maps = new((/4/),graphic)      ; maps
 plots = new((/dimsizes(xseas)/),graphic) ; bootstrapping stippling
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for gridded precip. and EF

 res			= True
 res@gsnDraw		= False
 res@gsnFrame		= False
 res@gsnAddCyclic      	= False    ; data already has cyclic point

 res@mpProjection	= "LambertEqualArea"
 res@mpGridAndLimbOn	= True
 res@mpGridLatSpacingF	= 10
 res@mpLimitMode	= "LatLon"
 res@mpMinLatF	 	= 25
 res@mpMaxLatF	 	= 50
 res@mpMinLonF	 	= 253
 res@mpMaxLonF	 	= 290.
 res@mpCenterLonF 	= 260
 res@mpCenterLatF	= 40.0
 res@mpGridLineDashPattern 	= 2  
 res@mpGridLineThicknessF 	= 0.25
 res@pmTickMarkDisplayMode	= "Always"  	 ; turn on fancy tickmarks
 
 res@cnLineLabelsOn 		= False
 res@cnFillOn			= True     ; turn on color fill
 res@cnLinesOn  		= False    ; turn of contour lines
 res@cnLevelSelectionMode 	= "ManualLevels"     ; set manual contour levels
 res@cnFillColors 		= (/19,17,15,13,11,10,8,6,4,2/)
 
 res@lbLabelBarOn 		= True
 res@lbLabelFontHeightF 	= 0.015
 res@lbTitlePosition 		= "Bottom"
 res@pmLabelBarOrthogonalPosF 	= .17	      ; move whole thing down

 res@gsnMaximize 		= False
 res@gsnLeftString 		= ""
 res@gsnRightString 		= ""
 res@tmYLLabelsOn 		= False
 res@tmXBLabelsOn 		= False
 res@tmYRLabelsOn 		= False
 res@tmXTLabelsOn 		= False
 res@tmYLOn 			= False
 res@tmXBOn 			= False
 res@tmYROn 			= False
 res@tmXTOn 			= False  

 res@gsnCenterStringFontHeightF = 0.02
 res@tiYAxisFontHeightF 	= 0.035
 res@tiYAxisFontColor 		= "black"
 res@tiYAxisString 		= ""  
 
 opt = True   ; resources for bootstrapping
 opt@gsnShadeFillType = "pattern" ; pattern fill 
 opt@gsnShadeHigh = 17 
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for moisture fluxes
 res_vc 		= True
 res_vc@gsnDraw		= False
 res_vc@gsnFrame	= False
 res_vc@gsnAddCyclic   	= False    ; da
 res_vc@mpProjection	= "LambertEqualArea"
 res_vc@mpGridAndLimbOn	= True
 res_vc@mpGridLatSpacingF	= 10
 res_vc@mpLimitMode	= "LatLon"
 res_vc@mpMinLatF	= 25
 res_vc@mpMaxLatF	= 50
 res_vc@mpMinLonF	= 253 
 res_vc@mpMaxLonF	= 290.
 res_vc@mpCenterLonF 	= 260
 res_vc@mpCenterLatF	= 40.0
 res_vc@mpGridLineDashPattern 	= 2  
 res_vc@mpGridLineThicknessF 	= 0.25
 res_vc@pmTickMarkDisplayMode 	= "Always"  	 ; turn on fancy tickmarks
 res_vc@cnLineLabelsOn 		= False

 res_vc@vcRefAnnoOrthogonalPosF = -0.68		; move ref vector up
 res_vc@vcRefMagnitudeF	     	= 5.0		; define vector ref mag
 res_vc@vcRefLengthF	     	= 0.045		; define length of vec ref
 res_vc@vcGlyphStyle	    	= "CurlyVector"	; turn on curly vectors
 res_vc@vcMinDistanceF	     	= 0.017
 res_vc@vcLineArrowColor	= "black"  	 ; change vector color
 res_vc@vcLineArrowThicknessF   = 0.5		 ; change vector thickness
 res_vc@vcRefAnnoString1On 	= True
 res_vc@vcRefAnnoString1 	= "5 g kg~S~-1~N~ m s~S~-1~N~"
 res_vc@vcRefAnnoFontHeightF 	= 0.015
 res_vc@vcRefAnnoString2On 	= False
 res_vc@vcRefAnnoSide          	= "Bottom"
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for lat/lon labels 
 tmres = True
 tmres@tmYLValues = ispan(20,60,10)
 tmres@tmYRLabelFontHeightF = 0.015
 tmres@tmXBValues = ispan(-135,-30,15)
 tmres@tmXBLabelFontHeightF = 0.015
 tmres@tmYLLabelFontHeightF = 0.015
 tmres@YUseLeft = False
;******************************************************************************************************************

;******************************************************************************************************************
; resources for box and bootstrapping
 ypts = (/ 30, 30, 40, 40, 30/) 	; lats of region
 xpts = (/ -105, -85, -85, -105, -105/) ; lons of region

 resB		       	= True		; polyline mods desired
 resB@gsnDraw 		= False
 resB@gsnFrame 		= False
 resB@cnFillOn 		= False
 resB@cnInfoLabelOn   	= False		; turn off contour label
 resB@cnLineLabelsOn 	= False
 resB@cnLinesOn 	= False   	; turn of contour lines  
 resB@cnMinLevelValF	= 0. 	      ; set min contour level
 resB@cnMaxLevelValF	= 10.	       ; set max contour level
 resB@cnLevelSpacingF	= 0.01		; set contour spacing
 resB@cnMonoFillScale  	= True
 resB@cnFillScaleF 	= 0.8
 resB@cnFillColor 	= "black"
;******************************************************************************************************************

;******************************************************************************************************************
; loop through each precipitation, hflx and moisture flux files, to draw panels (a) and (b)

do i=0,dimsizes(vars)-1
 
 var = vars(i)
 print(var+"")

 infile = addfile(var+"_based_on_hwf_top_rankd_8_hottest_gp_JJA_from_daily_95pctl_"+years(0)+\
	"-"+years(dimsizes(years)-1)+"_bootStrap_"+nBoot+"_"+xseas_names+"_seas.nc","r")

;------------------------------------------------------------------------------------------------------------------
;moisture transport
 uq_atl_f = addfile("uq850_xmvq_ATL_ensmean_1930-1937_monthly_clim_120-75W_20-60N_grid.nc","r")
 uq_pac_f = addfile("uq850_xmvq_PAC_ensmean_1930-1937_monthly_clim_120-75W_20-60N_grid.nc","r")
 vq_atl_f = addfile("vq850_xmvq_ATL_ensmean_1930-1937_monthly_clim_120-75W_20-60N_grid.nc","r") 
 vq_pac_f = addfile("vq850_xmvq_PAC_ensmean_1930-1937_monthly_clim_120-75W_20-60N_grid.nc","r") 

 uq_atl = rm_single_dims(uq_atl_f->uq)
 vq_atl = rm_single_dims(vq_atl_f->vq)
 uq_pac = rm_single_dims(uq_pac_f->uq)
 vq_pac = rm_single_dims(vq_pac_f->vq)

; convert to g/kg m/s
 uq_atl_tmp = uq_atl*1000 
 vq_atl_tmp = vq_atl*1000
 uq_pac_tmp = uq_pac*1000
 vq_pac_tmp = vq_pac*1000

 copy_VarCoords(uq_atl,uq_atl_tmp)
 copy_VarCoords(vq_atl,vq_atl_tmp)
 copy_VarCoords(uq_pac,uq_pac_tmp)
 copy_VarCoords(vq_pac,vq_pac_tmp)
 
; April-May averages
 uq_atl_am = dim_avg_n_Wrap(uq_atl_tmp(3:4,:,:),0)
 vq_atl_am = dim_avg_n_Wrap(vq_atl_tmp(3:4,:,:),0)
 uq_pac_am = dim_avg_n_Wrap(uq_pac_tmp(3:4,:,:),0)
 vq_pac_am = dim_avg_n_Wrap(vq_pac_tmp(3:4,:,:),0)
 
; difference between ATL and PAC ensembles
 uq_am_diff = uq_atl_am - uq_pac_am
 vq_am_diff = vq_atl_am - vq_pac_am
 
 copy_VarCoords(uq_atl_am,uq_am_diff)
 copy_VarCoords(vq_atl_am,vq_am_diff)
;------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------
;prcp and EF 

; call in prcp/EF data (diff = difference between ATL and PAC already calculated)
 if (var.eq."ef") then
  diff := infile->diff_anom_avg
 else
  diff := infile->diff_anom_avg
 end if 

 atl := infile->atl_anom_avg
 pac := infile->pac_anom_avg

;land sea mask
 a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
 lsm_a = landsea_mask(a->LSMASK,atl&latitude,atl&longitude)
 atl = mask(atl,lsm_a.eq.0.or.lsm_a.eq.2,False)        ; mask out all ocean points from data
 pac = mask(pac,lsm_a.eq.0.or.lsm_a.eq.2,False)   
 diff = mask(diff,lsm_a.eq.0.or.lsm_a.eq.2,False)

 if (var.eq."prcp") then
  res@cnMinLevelValF	:= -0.6  	      ; set min contour level
  res@cnMaxLevelValF	:= 0.6 	      ; set max contour level
  res@cnLevelSpacingF	:= .15 	      ; set contour spac
  long_name 		= "Precipitation"
  res@lbTitleString    	= "mm day~S~-1~N~"
  res@lbTitleFontHeightF= 0.015
  res@vpHeightF		= 0.25		   ; change aspect ratio of plot
  res@vpWidthF 		= 0.325        
  res@vpXF     		= 0.1		      ; start plot at x ndc coord 
  res@vpYF     		= 0.8		      ; start plot at y ndc coord   
  res@gsnLeftString 	= "~F22~a"
  res@gsnLeftStringFontHeightF = 0.02
 end if
 if (var.eq."ef") then
  res@cnMinLevelValF	:= -0.8  	      ; set min contour level
  res@cnMaxLevelValF	:= 0.8 	      ; set max contour level
  res@cnLevelSpacingF	:= .2 	      ; set contour spac
  long_name 		= "Evaporative fraction"
  res@lbTitleString    	= "(~F18~U~F21~10~S~-1~N~)"
  res@vpXF     		= 0.525		   
  res@vpYF     		= 0.8		   
  res@tiMainString    	= "~F33~D~F21~(ATL~B~HIST~N~, PAC~B~HIST~N~)"
  res@tiMainOffsetXF 	= -0.23
  res@tiMainFontHeightF = 0.025
  res@gsnLeftString 	= "~F22~b" 
 end if 

 res@gsnCenterString 	= long_name  ; add long name to center string
  
;plot precip, EF and moisture fluxes 
 if (var.eq."ef") then
  diff_10 := diff*10    ; scale up EF
  copy_VarCoords(diff,diff_10)
  maps(i)=gsn_csm_contour_map(wks,diff_10,res)
 else
  maps(i)=gsn_csm_contour_map(wks,diff,res)
 end if
 
 if (i.eq.0) then
  vecs=gsn_csm_vector(wks,uq_am_diff,vq_am_diff,res_vc)
  overlay(maps(i),vecs)
 end if
 
 maps(i) = add_map_tickmarks(wks,maps(i),tmres)

; add in bootstrapping stippling (already calculated)
 if (var.eq."prcp") then 
  diffBootHi  := infile->diffBootHi(0,0,:,:)
  diffBootLow := infile->diffBootLow(0,0,:,:)
 else
  diffBootHi  := infile->diffBootHi(0,:,:)
  diffBootLow := infile->diffBootLow(0,:,:)
 end if   

 diff_boot := abs(where(diff.ge.diffBootHi.or.diff.le.diffBootLow,diff,diff@_FillValue))
 
 copy_VarCoords(diff,diff_boot)
 plots(i) = gsn_csm_contour(wks,diff_boot,resB) ; contours are at 95,100 
 plots(i) = gsn_contour_shade(plots(i),-1000,0,opt) ; pattern fill all areas   

 overlay(maps(i),plots(i))

; draw southern Great plains outline in panel (b)
 if (i.eq.1) then
  box = gsn_add_polyline(wks,maps(i),xpts,ypts,resB)      
 end if

end do ; i
;------------------------------------------------------------------------------------------------------------------
;******************************************************************************************************************

;******************************************************************************************************************
; plot the annual cycles of the bare soil runs
soil_runs = (/"xmvqu_r69_soil","xmvqt_r69_soil","xmvqs_r69_soil"/)  ; names of HadGEM3 bare soil simulations (30%, 50%, 80%)
soil_seas = new((/nvars,dimsizes(month_list),dimsizes(soil_runs)+3/),float)

hist_runs = (/"xmvpa_r69","xmvpb_r115","xmvpc_r396","xmvpd_r1059",\ ; names of HadGEM3 HIST simulations
	       "xmvpe_r1169","xmvpf_r1346","xmvpg_r400","xmvph_r137",\
               "xmvpi_r1466","xmvpj_r1194"/)
hist_seas = new((/nvars,dimsizes(month_list),dimsizes(hist_runs)+3/),float)

; loop throuh precip and EF 
do k=0,nvars-1
 var=vars(k)

; loop through soil runs
 do i=0,dimsizes(soil_runs)-1
  soil_run 	:= soil_runs(i)
;  ip_time 	:= (years*100) + mon_fac  ; get time in YYYYMM

  if (var.eq."prcp") then
   soil_fils 	:= systemfunc ("ls prcp_"+soil_run+"_**monthly.nc*")
   soil_fil 	:= addfile(soil_fils,"r")
   var1		:= soil_fil->$var$(:,{latS:latN},{lonL:lonR})
   latitude 	:= var1&latitude 
   var2 	:= var1 * 86400  ; convert prcp to mm/day
   copy_VarCoords(var1,var2)
   var1 	:= var2
  end if

  if (var.eq."ef") then
   soil_fils 	:= systemfunc ("ls lhflx_"+soil_run+"_**monthly.nc* shflx_"+soil_run+"_**monthly.nc*") ; file paths
   soil_fil 	:= addfile(soil_fils(0),"r")
   soil_fil1 	:= addfile(soil_fils(1),"r")
   lhflx 	:= soil_fil->lhflx(:,{latS:latN},{lonL:lonR})
   shflx 	:= soil_fil1->shflx(:,{latS:latN},{lonL:lonR})
   var1 	:= (lhflx/(lhflx+shflx)) ; calculate EF
   copy_VarCoords(lhflx,var1)
   var1 = where(var1.le.0 .or. var1.gt.1 ,var1@_FillValue,var1)
   copy_VarCoords(lhflx,var1)
   latitude 	:= var1&latitude 
  end if

  time		:=soil_fil->time
  yyyymm 	:= cd_calendar(time, -1)

; loop through each month to calculate average precip. and EF
  do j=0,dimsizes(month_list)-1   
   iyyyy 	:= get1Dindex(floattoint(yyyymm),((years*100) + month_list(j)))  ;
   var_int 	:= var1(iyyyy,:,:)
   clat 	:= cos(latitude*rad)
   var_ave 	:= dim_avg_n_Wrap(wgt_areaave(var_int, clat, 1.0, 0),0)
   soil_seas(k,j,i) = var_ave
  end do ; j (seasons)
 end do ; i (soil_runs)

; average of all ensemble members, and calculate stdev.
 soil_seas(k,:,dimsizes(soil_runs)) = dim_avg_n_Wrap(soil_seas(k,:,0:dimsizes(soil_runs)-1),1)

end do ; k

 prcp_all = new((/3,dimsizes(soil_seas(0,:,0))/),float)
 ef_all = new((/3,dimsizes(soil_seas(0,:,0))/),float)
 prcp_all(0,:) = soil_seas(0,:,0)
 prcp_all(1,:) = soil_seas(0,:,1)
 prcp_all(2,:) = soil_seas(0,:,2)
 ef_all(0,:) = soil_seas(1,:,0)
 ef_all(1,:) = soil_seas(1,:,1)
 ef_all(2,:) = soil_seas(1,:,2) 

;**************************************************************************************************
; HIST runs
do k=0,nvars-1
 var=vars(k)
 
 do i=0,dimsizes(hist_runs)-1
 
  hist_run = hist_runs(i)

  if (var.eq."ef") then
   hist_fils 	:= systemfunc ("ls lhflx_"+hist_run+"_**monthly.nc* shflx_"+hist_run+"_**monthly.nc*") ; file paths
   hist_fil 	:= addfile(hist_fils(0),"r")
   hist_fil1 	:= addfile(hist_fils(1),"r")
   lhflx 	:= hist_fil->lhflx(:,{latS:latN},{lonL:lonR})
   shflx 	:= hist_fil1->shflx(:,{latS:latN},{lonL:lonR})
   var1 	:= (lhflx/(lhflx+shflx))
   var1 	= where(var1.le.0 .or. var1.gt.1,var1@_FillValue,var1)
   copy_VarCoords(lhflx,var1)
   latitude 	:= var1&latitude 
  end if
  
  if (var.eq."prcp") then
   hist_fils 	:= systemfunc ("ls prcp_"+hist_run+"_**monthly.nc*")
   hist_fil 	:= addfile(hist_fils,"r")
   var1 	:= hist_fil->$var$(:,{latS:latN},{lonL:lonR})
   latitude 	:= var1&latitude
   var2 	:= var1 * 86400
   copy_VarCoords(var1,var2)
   var1 	:= var2
  end if
  
  time 		:= hist_fil->time
  yyyymm  	:= cd_calendar(time, -1)
 
  do j=0,dimsizes(month_list)-1
   iyyyy 	:= get1Dindex(floattoint(yyyymm),((years*100) + month_list(j)))  ;
   iyyyy_indx 	:= ind(.not.ismissing(iyyyy))
   var_int 	:= var1(iyyyy(iyyyy_indx),:,:)
   clat 	:= cos(latitude*rad)
   var_ave 	:= dim_avg_n_Wrap(wgt_areaave(var_int, clat, 1.0, 0),0) ; weighted averaged
   hist_seas(k,j,i) = var_ave
  end do ; j (months)
 end do ; i (hist_runs)

 hist_seas(k,:,dimsizes(hist_runs)) = dim_avg_n_Wrap(hist_seas(k,:,0:dimsizes(hist_runs)-1),1)

end do ; k

; create arrays for HIST precip. and EF (10 members x 12 months)
 prcp_hist     = new((/10,dimsizes(hist_seas(0,:,0))/),float)
 ef_hist       = new((/10,dimsizes(hist_seas(0,:,0))/),float)

 do k=0,9
  prcp_hist(k,:) = hist_seas(0,:,k) 
  ef_hist(k,:)   = hist_seas(1,:,k) 
 end do ; k

; append precip. and EF from HIST to bare soil runs for plotting
 prcp_both 	= array_append_record(prcp_hist,prcp_all,0)
 ef_both 	= array_append_record(ef_hist,ef_all,0)
 
;**************************************************************************************************
; resources for time series plots
 resTS                  = True                      ; plot mods desired
 resTS@gsnFrame 	= False		      ; don't advance frame yet  
 resTS@gsnDraw 		= False		      ; don't advance frame y
 resTS@xyDashPattern  	= 0                         ; Make curves all solid 
 resTS@xyLineThicknesses= (/1,1,1,1,1,1,1,1,1,1,1,2,4/)          ; make second line thicker
 resTS@xyLineColors    	= (/"grey","grey","grey","grey",\
 			"grey","grey","grey","grey","grey","grey",\
			 "orange","red","magenta"/)          ; change line color

 resTS@tmXBMode	       	= "Explicit"		 ; explicit labels
 resTS@tmXBValues       = month_list		 ; x axis values
 resTS@tmXBLabels      	= (/"J","F","M","A","M","J","J","A","S","O","N","D"/)		 ; labels themselves 
 resTS@tmXBLabelFontHeightF 		= 0.015
 resTS@tmXTOn 		= False
 resTS@tmYLMode	       	= "Manual"	; explicit labels
 resTS@tmYLMinorOn	= True		; turn the minor tick marks on
 resTS@tmYLPrecision 	= 2	       ; set the precision to 2 significant digits
 resTS@tmYLTickStartF  	= 1.4
 resTS@tmYLTickEndF    	= 4.6
 resTS@tmYLTickSpacingF	= 1 
 resTS@tmYLLabelFontHeightF 		= 0.015

 resTS@vpHeightF	= 0.15		      ; change aspect ratio of plot
 resTS@vpWidthF 	= 0.325	
 resTS@vpXF     	= 0.1                   ; start plot at x ndc coord 
 resTS@vpYF     	= 0.32                   ; start plot at y ndc coord 

 resTS@trXMinF  	= 0.5		       ; min value on y-axis
 resTS@trXMaxF  	= 12.5		       ; max value on y-axis
 resTS@trYMinF  	= 1.4		       ; min value on y-axis
 resTS@trYMaxF  	= 4.6		       ; max value on y-axis
 resTS@gsnLeftStringFontHeightF 	= 0.02
 resTS@gsnLeftStringOrthogonalPosF 	= 0.02
 resTS@gsnLeftString 			= "~F22~c"
 resTS@gsnCenterString 			= "Precipitation"
 resTS@gsnCenterStringFontHeightF 	= 0.02
 
 resTS@tiYAxisString 		= "mm day~S~-1~N~"
 resTS@tiYAxisFontHeightF 	= 0.015
 resTS@tiXAxisString 		= "Month"
 resTS@tiXAxisFontHeightF 	= 0.015 

 maps(2)  =  gsn_csm_xy (wks,month_list,prcp_both,resTS) ; create plot

 resTS@vpXF     	= 0.525                   ; start plot at x ndc coord 
 
 resTS@tmYLTickStartF  	:= 0.44 
 resTS@tmYLTickEndF    	:= 0.74 
 resTS@tmYLTickSpacingF	:= 0.08 

 resTS@tiYAxisString 	= ""
 resTS@tiMainString    	:= "~F21~HIST & bare soil runs"
 resTS@tiMainOffsetXF 	= -0.23
 resTS@tiMainFontHeightF = 0.025 
 resTS@trYMinF  	:= 0.44   ; min value on y-axis
 resTS@trYMaxF  	:= 0.74   ; max value on y-ax 
 resTS@gsnLeftString 	= "~F22~d"
 resTS@gsnCenterString 	= "Evaporative fraction"

 maps(3)  = gsn_csm_xy (wks,month_list,ef_both,resTS) ; create plot
;**************************************************************************************************

;**************************************************************************************************
; Manually create and attach legend for time series
 resL_text		      = True		      ; text mods desired
 resL_text@txFontHeightF      = 0.013		      ; change text size
 resL_text@txJust	      = "CenterLeft"	      ; text justification

 resL_lines		      = True		      ; polyline mods desired
 resL_lines@gsLineDashPattern = 0.		      ; solid line
 resL_lines@gsLineThicknessF  = 1.		      ; line thicker
 resL_lines@gsLineColor       = "orange"		 ; line color

 xxx 	= (/7.7,8.2/)
 yyy 	:= (/4.4,4.4/)
 dum1 	= gsn_add_polyline(wks,maps(2),xxx,yyy,resL_lines)	      ; add polyline
 dum2 	= gsn_add_text(wks,maps(2),"30%",8.5,4.4,resL_text); add text

 resL_lines@gsLineThicknessF  = 2.		      ; line thicker
 resL_lines@gsLineColor       = "red"		      ; line color
 yyy 	:= (/3.9,3.9/); (/3.25,3.25/)
 dum3 	= gsn_add_polyline(wks,maps(2),xxx,yyy,resL_lines)	      ; add polyline
 dum4 	= gsn_add_text(wks,maps(2),"50%",8.5,3.9,resL_text); add text

 resL_lines@gsLineThicknessF  = 4.		      ; line thicker
 resL_lines@gsLineColor       = "magenta"		  ; line color
 yyy 	:= (/3.4,3.4/);(/2.75,2.75/)
 dum5 	= gsn_add_polyline(wks,maps(2),xxx,yyy,resL_lines)	      ; add polyline
 dum6 	= gsn_add_text(wks,maps(2),"80%",8.5,3.4,resL_text); add text
 
 xxx 	:= (/1,1.5/)
 resL_lines@gsLineThicknessF  = 1.		      ; line thicker
 resL_lines@gsLineColor       = "grey"  	       ; line color
 yyy 	:= (/4.4,4.4/);(/2.75,2.75/)
 dum7 	= gsn_add_polyline(wks,maps(2),xxx,yyy,resL_lines)	      ; add polyline
 dum8 	= gsn_add_text(wks,maps(2),"HIST",1.8,4.4,resL_text); add text  
 
;**************************************************************************************************
            
 draw(maps) ; draw the figures
 frame(wks)
 delete(wks)
 system("convert -density 144x144 -trim " + outfile + ".eps " + outfile + ".png")

end 
