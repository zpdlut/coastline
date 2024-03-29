PRO newcoastline
  ;originImg=READ_IMAGE('E:\IDLWorkspace83\newcoastline\12.png')
  ;originImg=READ_TIFF('F:\IDLworkspace\coastline\subset_VV.tif',R, G, B,GEOTIFF=GeoKeys,INTERLEAVE = 0)
  originImg=READ_TIFF('C:\Users\name\IDLWorkspace83\coastline\subset_VV.tif',R, G, B,GEOTIFF=GeoKeys,INTERLEAVE = 0)
  ;originImg=READ_tiff('E:\IDLworkspace83\newcoastline\waxlake_tm5_1984312_geo.tif',GEOTIFF=GeoKeys)
  ;Img=transpose(rotate(DOUBLE(REFORM(originImg[0,2000:2399,2000:2399])),1))
  ;Img=DOUBLE(originImg[0:500,400:900])
  Img=DOUBLE(originImg)
  HELP,IMG 
  ;plot, transpose(img,[0,2,1])
  timestep=5;   time step
  mu=0.2/timestep;coefficient of the distance regularization term R(phi)
  iter_inner=5
  iter_outer=300
  ;iter_outer=120
  lambda=5;coefficient of the weighted length term L(phi)
  ;alfa=1.5;coefficient of the weighted area term A(phi)
  alfa=5000; 
  epsilon=1.5;papramater that specifies the width of the DiracDelta function
  sigma=1.5;scale parameter in Gaussian kernel
  ;  Gauss=GAUSSIAN_FUNCTION([sigma,sigma],/double,width=15);gauss核
  ;  Img_smooth=convol(Img,gauss,/CENTER, /EDGE_TRUNCATE);卷积
  Img_smooth = GAUSS_SMOOTH(Img , sigma,/EDGE_ZERO); /EDGE_ZERO gauss平滑
  iGrad=gradient(Img_smooth,/vector);
  Ix=iGrad[*,*,0]
  Iy=iGrad[*,*,1]
  f=Ix^2+Iy^2;
  g=1/(1+f);
  c0=2
  imgsize=SIZE(Img)
  ;创建矩阵
  initialLSF=MAKE_ARRAY(imgsize[1],imgsize[2],/double,/NOZERO,/TPOOL_MIN_ELTS)
  initialLSF=initialLSF+c0
  ;initialLSF[0:500,0:370]=-c0
  ;initialLSF[0:289,0:279]=-c0
  ;initialLSF[2:499,80:499]=-c0
  initialLSF[2:1478,2:1559]=-c0
  phi=initialLSF


  ;显示初始level——set
  ;im = IMAGE(originImg[*,2000:2399,2000:2399], RGB_TABLE=13, TITLE='Coastline')
  ;im = IMAGE(originImg[0:500,400:900], TITLE='Coastline',/OVERPLOT)
  im = IMAGE(originImg, TITLE='Coastline',/OVERPLOT)
  c=CONTOUR(phi, C_LINESTYLE=0,c_label_show=0,COLOR=[0,255,0] ,c_value=[0,0] , /OVERPLOT)
  
  potential=2;
  IF potential EQ 1 THEN BEGIN
    potentialFunction = 'single-well';use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model
  ENDIF ELSE BEGIN
    IF potential EQ 2 THEN potentialFunction = 'double-well' ELSE potentialFunction = 'double-well'
  END
  FOR n=1,iter_outer DO BEGIN
    tic
    phi=drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction)
    toc
    IF (n MOD 2) EQ 0 THEN BEGIN
      c.erase
      ;im = IMAGE(originImg[*,2000:2399,2000:2399], RGB_TABLE=13, TITLE='Coastline',/OVERPLOT)
      im = IMAGE(originImg, TITLE='Coastline',/OVERPLOT)
      ;im = IMAGE(originImg[0:500,400:900], TITLE='Coastline',/OVERPLOT)
      c = CONTOUR(phi, C_LINESTYLE=0,c_label_show=0,COLOR=[0,255,0] ,c_value=[0,0] ,/OVERPLOT,/)
    ENDIF
    print,n
    print,systime()
  ENDFOR
  alfa=0;
  iter_refine = 10;
  phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction)
  help,phi
  c.erase
  ;im = IMAGE(originImg[0:500,400:900],  TITLE='Coastline',/OVERPLOT)
  im = IMAGE(originImg, TITLE='Coastline',/OVERPLOT)
  c = CONTOUR(phi, C_LINESTYLE=0,c_label_show=0,COLOR=[0,255,0] ,c_value=[0,0] ,/OVERPLOT)
END
