;***************************************************
;
; Fig3_spread_ATL_PAC_slp_hgt.ncl
;
;
; This script calls in 1-week averaged MSLP and Z500 associated
; with the hottest summer heatwaves over 1930-37 from
; 20CR, HadGEM3 HIST, ATL and PAC. 
; 
;
;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$WORK/ncl_scripts/append_xmgrace.ncl"
load "$WORK/ncl_scripts/random_array.ncl"
load "$WORK/ncl_scripts/get1Dindex_mult.ncl"
load "$WORK/ncl_scripts/percent_to_value.ncl"
load "$WORK/ncl_scripts/tickmarks.ncl" ; for LambertEqualArea plots
;****************************************************

 err = NhlGetErrorObjectId() 
  
 setvalues err 
   "errLevel" : "Fatal" ; only report Fatal errors 
 end setvalues 

begin

;******************************************************************************************************************
; variables to set 
 type = "hottest" ; hottest heatwaves
 period = "1weeks" ; 1 week averaged circulation
 seas = "JJA" ; choose summer circulation
 years = ispan(1930,1937,1) ; Dust bowl period
 nyears = dimsizes(years) ; number of Dust bowl years
 exps = (/"hA-hP","hA-cP","hP-cA"/) ; HadGEM3 ensembles -> HIST, ATL_HIST & PAC_HIST
 long_names = (/"HIST","ATL~B~HIST","PAC~B~HIST"/) ; ensemble labels
 nexps = dimsizes(exps) ; number of ensembles (3)
 setfileoption("nc","SuppressClose",False)

 if (seas.eq."JJA") then
  getseas = 2 ; indx for getting the correct season
 end if
 if (type.eq."hottest") then
  gettype = 2 ; indx for getting the correct heatwave type
 end if
 ;******************************************************************************************************************

;******************************************************************************************************************
; plotting parameters
 outfile = "fig3_HadGEM3_20CR_"+type+"_HW_"+period+"_"+\    ; outfile of image
            seas+"_1930-37_mslp_z500"
 wks = gsn_open_wks("eps", outfile)     ; Open a workstation and
 maps = new((/4/),graphic) ; four panels for the figure
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for Z500
 res			 = True
 res@gsnDraw		 = False
 res@gsnFrame		 = False
 res@gsnAddCyclic        = False    ; data already has cyclic point
	
 res@cnFillOn		  = True     ; turn on color fill
 res@cnLinesOn		  = False    ; turn off contour lines
 res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
 res@lbLabelFontHeightF = 0.03
 res@lbTitleFontHeightF = 0.03
 res@lbTitlePosition = "Bottom"
 res@lbBoxEndCapStyle = "TriangleBothEnds"
 res@lbTitleString = "m" ; Z500 units
 res@pmLabelBarWidthF = 1.2
 res@pmLabelBarOrthogonalPosF = .17           ; move whole thing down
 res@gsnCenterStringFontHeightF = 0.03
 
 res@gsnLeftString  = ""
 res@gsnRightString = ""
 res@cnInfoLabelOn  = False                      ; turn off contour label
 res@cnLineLabelsOn = False

 res@tmYLOn = False
 res@tmXBOn = False
 res@tmYROn = False
 res@tmXTOn = False 
 res@tmYLOn = False				; turn off left Y left axis
 res@tmYROn = True				; turn on right Y right axis
 res@tmXBOn = True				; turn on bottom X axis
 res@tmXTOn = False  				; turn off top X axis
 res@tmYLLabelsOn = False
 res@tmXBLabelsOn = False
 res@tmYRLabelsOn = False
 res@tmXTLabelsOn = False
 res@tmYRLabelFontHeightF = 0.04
 res@tmXBLabelFontHeightF = 0.04 
 res@tmXBMinorOn	= False 	  ; no lon minor tickmarks
 res@tmYLMinorOn	= False 	  ; no lon minor tickmarks
 res@tmYUseLeft = False
   
 res@gsnMajorLatSpacing = 10		  ; change maj lat tm spacing
 res@gsnMajorLonSpacing = 10		  ; change maj lon tm spacing

 res@mpProjection	   = "LambertEqualArea" ; type of projection
 res@mpGridAndLimbOn	   = True
 res@mpGridLatSpacingF     = 10
 res@mpLimitMode	   = "LatLon"
 res@mpMinLatF  = 10.
 res@mpMaxLatF  = 60.
 res@mpMinLonF  = 210.
 res@mpMaxLonF  = 330.
 res@mpCenterLonF = 270.
 res@mpCenterLatF	  = 30.0
 res@pmTickMarkDisplayMode  = "Always"		; turn on fancy 
 res@mpGridLineDashPattern = 2  
 res@mpGridLineThicknessF = 0.25

 res@tiYAxisFontHeightF = 0.04
 res@tiYAxisFontColor = "black"

 res@cnFillPalette = "BlueDarkRed18"  ; contour color palette
 colors    = (/3,4,5,6,7,9,11,12,13,14,15,16/) ; values for color palette
 res@cnFillColors    = colors 
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for lat/lon labels
 tmres = True
 tmres@tmXBValues = ispan(-135,-30,30) ; values of longitudes
 tmres@tmXBLabelFontHeightF = 0.025    ; label font heights
 tmres@tmYRLabelFontHeightF = 0.025    ; label font heights
 tmres@YUseLeft = False
 tmres@tmYRValues = ispan(10,50,10)    ; values of latitudes
;******************************************************************************************************************

;******************************************************************************************************************
; map resources for MSLP  
 sres = True
 sres@cnLevelSelectionMode = "ManualLevels"	; set manual contour levels
 sres@mpProjection	   = "LambertEqualArea" 
 sres@mpGridAndLimbOn	   = True
 sres@mpGridLatSpacingF    = 10
 sres@mpLimitMode	   = "LatLon"
 sres@gsnDraw  = False
 sres@gsnFrame = False
 sres@gsnAddCyclic = False    ; data already has cyclic point
 sres@gsnContourNegLineDashPattern = 1       ; sets negative contours to dash pattern 1
 sres@gsnContourZeroLineThicknessF = 2        ; sets thickness of zero contour to 2 (default=1)
 sres@cnLineLabelsOn = True
 sres@cnLineLabelPlacementMode = "constant"
 sres@cnInfoLabelOn   = True			  ; turn off contour label
 sres@cnInfoLabelOrthogonalPosF = -0.1
 sres@cnInfoLabelFontHeightF = 0.015
;********************************************************************************************************************

;******************************************************************************************************************** 
; loop through each experiment type  
do j=0,dimsizes(exps)-1

 expm = exps(j)
 res@gsnCenterString = long_names(j)

 if (expm.eq."hA-hP") then
  infiles_mslp := systemfunc ("ls mslp*xmvp**_"+period+"**from_ref_xmvp_ens22.nc") 	     ; HIST MSLP files
  infiles_hgt := systemfunc ("ls hgt*xmvp*_"+period+"**from_ref_xmvp_ens22.nc")		     ; HIST Z500 files
 end if 
 if (expm.eq."hP-cA") then
  infiles_mslp := systemfunc ("ls mslp*xmvq**hA-cP**_"+period+"**from_ref_xmvp_ens22.nc") 	   ; PAC_HIST MSLP files
  infiles_hgt := systemfunc ("ls hgt*xmvq*hA-cP*_"+period+"**from_ref_xmvp_ens22.nc")	           ; PAC_HIST Z500 files 
 end if
 if (expm.eq."hA-cP") then
  infiles_mslp := systemfunc ("ls mslp*xmvq**hP-cA**_"+period+"**from_ref_xmvp_ens22.nc")          ; ATL_HIST MSLP files
  infiles_hgt := systemfunc ("ls hgt*xmvq**hP-cA*_"+period+"**from_ref_xmvp_ens22.nc")             ; ATL_HIST Z500 files 
 end if 

 infile_mslp := addfiles(infiles_mslp,"r")
 ListSetType (infile_mslp, "join")	  ; concatenate MSLP files
 mslp := infile_mslp[:]->mslp(:,getseas,gettype,{years},:,:)	  	    ; call in MSLP data
 latitude := infile_mslp[0]->latitude					    ; latitudes of gridded data
 longitude := infile_mslp[0]->longitude					    ; longitudes of gridded data

 infile_hgt := addfiles(infiles_hgt,"r")
 ListSetType (infile_hgt, "join")	  ; concatenate Z500 files
 hgt := infile_hgt[:]->hgt(:,getseas,gettype,{years},:,:)	  	    ; call in Z500 data
;******************************************************************************************************************** 

;******************************************************************************************************************** 
; average over time and ensemble members 
 Avg_mslp := dim_avg_n_Wrap(mslp,1)  ; average over 1930-37
 Avg_mslp_hPa := Avg_mslp/100  				  ; covert from Pa to hPa
 copy_VarCoords(Avg_mslp,Avg_mslp_hPa)			  ; copy coordinate variables across to MSLP average
 Avg_hgt := dim_avg_n_Wrap(hgt,1)    ; average over 1930-37
  
 ensAvg_mslp := dim_avg_n_Wrap(Avg_mslp_hPa,0)
 ensAvg_hgt  := dim_avg_n_Wrap(Avg_hgt,0)
;******************************************************************************************************************** 

;******************************************************************************************************************** 
; max/min values & intervals for MSLP and Z500
 if (j.eq.0) then
; values for 20CR and HIST
  sres@cnMinLevelValF	 = -3	     ; set min contour level for HIST MSLP
  sres@cnMaxLevelValF	 = 3	     ; set max contour level for HIST MSLP
  sres@cnLevelSpacingF	 = 1	     ; set contour spacing for HIST MSLP
  res@cnMinLevelValF	 = -40	     ; set min contour level for HIST Z500
  res@cnMaxLevelValF	 = 40	     ; set max contour level for HIST Z500
  res@cnLevelSpacingF	 = 8	     ; set contour spacing for HIST Z500
  sres@cnInfoLabelString = "Line interval 1 hPa"
 else
; values for ATL_HIST & PAC_HIST 
  sres@cnMinLevelValF	 := -2	     ; set min contour level for ATL_HIST & PAC_HIST MSLP
  sres@cnMaxLevelValF	 := 2	     ; set max contour level for ATL_HIST & PAC_HIST MSLP
  sres@cnLevelSpacingF	 := .5	     ; set contour spacing for ATL_HIST & PAC_HIST MSLP
  res@cnMinLevelValF	 := -20	     ; set min contour level for ATL_HIST & PAC_HIST Z500
  res@cnMaxLevelValF	 := 20	     ; set max contour level for ATL_HIST & PAC_HIST Z500
  res@cnLevelSpacingF	 := 4	     ; set contour spacing for ATL_HIST & PAC_HIST Z500
  sres@cnInfoLabelString = "Line interval 0.5 hPa"
 end if
;******************************************************************************************************************

;******************************************************************************************************************
; set up labelbar and plot each HadGEM3 ensemble
 if (j.eq.0 .or. j.eq.2) then
  res@lbLabelBarOn =  True
  res@pmLabelBarParallelPosF = -0.05
 else
  res@lbLabelBarOn = False  
 end if
    
 maps(j+1) = gsn_csm_contour_map_overlay(wks,ensAvg_hgt,ensAvg_mslp,res,sres)
 maps(j+1) = add_map_tickmarks(wks,maps(j+1),tmres)
 res@lbLabelBarOn = False

end do ; j
;******************************************************************************************************************** 

;******************************************************************************************************************** 
; Twentieth Century Reanalysis
 slp_infile = addfile("slp_BEST_1930-1940_1weeks_after_hw_dates_usa_JF-SON_obs_NEW.nc","r")   ; call in reanalysis file for MSLP
 hgt_infile = addfile("hgt_BEST_1930-1940_1weeks_after_hw_dates_usa_JF-SON_obs_NEW.nc","r")   ; call in reanalysis file for Z500
 slp  := slp_infile->slp(2,gettype,{years},:,:) ; 20CR MSLP
 hgt  := hgt_infile->hgt(2,gettype,{years},:,:) ; 20CR Z500
 time := slp_infile->time({years})		; 1930-37

 obs_avg_slp = dim_avg_n_Wrap(slp,0)  ; average 20CR MSLP over the Dust bowl period
 obs_avg_slp_hPa = obs_avg_slp/100    ; convert Pa --> hPa
 copy_VarCoords(obs_avg_slp,obs_avg_slp_hPa)
 obs_avg_hgt = dim_avg_n_Wrap(hgt,0)  ; average 20CR Z500 over the Dust bowl period 

 sres@cnMinLevelValF	= -3	    ; set min contour level for 20CR MSLP
 sres@cnMaxLevelValF	= 3	    ; set max contour level for 20CR MSLP
 sres@cnLevelSpacingF	= 1	    ; set contour spacing for 20CR MSLP
 res@cnMinLevelValF	= -40	    ; set min contour level for 20CR Z500
 res@cnMaxLevelValF	= 40	    ; set max contour level for 20CR Z500
 res@cnLevelSpacingF	= 8	    ; set contour spacing for 20CR Z500

 res@gsnCenterString = "20CR"
 sres@cnInfoLabelString = "Line interval 1 hPa"
 maps(0) = gsn_csm_contour_map_overlay(wks,obs_avg_hgt,obs_avg_slp_hPa,res,sres)
 maps(0) = add_map_tickmarks(wks,maps(0),tmres)
;******************************************************************************************************************** 

;******************************************************************************************************************** 
; create panel
 resP		       = True			; modify the panel plot
 resP@gsnFrame         = False  		; don't advance panel plot
 resP@gsnPanelLabelBar = False  		; add common colorbar	    
 resP@gsnPanelBottom   = 0.05		       ; add space at bottom ; turn off ususally
 resP@gsnPanelMainString = "MSLP and Z500 during the hottest heatwaves"     ; new resource added in NCL V6.4.0
 resP@gsnPanelFigureStrings= (/"~F22~a","~F22~b","~F22~c","~F22~d"/) ; add strings to panel
 resP@gsnPanelFigureStringsPerimOn = False
 resP@amJust   = "TopLeft"
 resP@gsnPanelFigureStringsFontHeightF = 0.015
 resP@gsnPanelYWhiteSpacePercent = 20
 resP@gsnPanelXWhiteSpacePercent = 1

 gsn_panel(wks,maps,(/2,2/),resP)

 frame(wks)
 delete(wks)
 system("convert -density 144x144 -trim " + outfile + ".eps " + outfile + ".png")

end 
