cp ../../native/Debug/FlyCapture2ANE.dll windows/FlyCapture2ANE.dll
jar xf FlyCapture2Extension.swc
del /F catalog.xml
move library.swf windows/
adt -package -target ane FlyCapture2Extension.ane extension.xml -swc FlyCapture2Extension.swc  -platform Windows-x86 -C windows . -platform default -C windows library.swf