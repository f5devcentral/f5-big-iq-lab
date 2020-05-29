#!/bin/bash
set -x

rm -f WEB-INF/classes/mypackage/Hello.class
javac --release 11 -cp "./WEB-INF/lib/gson-2.8.6.jar:./WEB-INF/lib/servlet-api.jar" src/Hello.java
mv src/Hello.class WEB-INF/classes/mypackage
rm -f ../ROOT.war
jar -cvf ../ROOT.war META-INF/ WEB-INF/ hello.jsp images/ index.html 