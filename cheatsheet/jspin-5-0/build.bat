javac -target 1.5 jspin\*.java
javac -target 1.5 spinSpider\*.java
javac -target 1.5 filterSpin\*.java
jar cfm jSpin.jar jspin\MANIFEST.MF jspin\*.class spinSpider\*.class filterSpin\*.class
pause
