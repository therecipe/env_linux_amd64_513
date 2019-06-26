#!/bin/bash

set -ev

QT_ROOT=/opt
QT_VERSION=5.13.0

rm -rf ./${QT_VERSION}
rm -rf ./Licenses


rsync -avz $QT_ROOT/Qt/${QT_VERSION}/gcc_64 ./${QT_VERSION}/
rsync -avz $QT_ROOT/Qt/Licenses .


rm -rf ./${QT_VERSION}/gcc_64/{doc,phrasebooks}
rm -rf ./${QT_VERSION}/gcc_64/lib/{cmake,pkgconfig,libQt5Bootstrap.a}


for v in *.jsc *.log *.pro *.pro.user *.qmake.stash *.qmlc .DS_Store *_debug* *.la *.prl; do
	find . -name ${v} -exec rm -rf {} \;
done

mkdir -p ./${QT_VERSION}/gcc_64/_bin
for v in moc qmake qmlcachegen qmlimportscanner qt.conf rcc uic; do
	mv ./${QT_VERSION}/gcc_64/bin/${v} ./${QT_VERSION}/gcc_64/_bin/
done
rm -rf ./${QT_VERSION}/gcc_64/bin && mv ./${QT_VERSION}/gcc_64/_bin ./${QT_VERSION}/gcc_64/bin

find ./${QT_VERSION}/gcc_64/bin -type f ! -name "qt.conf" -exec strip -s {} \;
find ./${QT_VERSION}/gcc_64/lib -type f ! -name "*.a" -name "lib*" -exec strip -s {} \;
find ./${QT_VERSION}/gcc_64/lib -type f -name "lib*.a" -exec strip -S {} \;
find ./${QT_VERSION}/gcc_64/plugins -type f -name "lib*" -exec strip -s {} \;
find ./${QT_VERSION}/gcc_64/qml -type f -name "lib*" -exec strip -s {} \;

mv $QT_ROOT/Qt $QT_ROOT/Qt_orig

go run ./patch.go

gzip -n ./${QT_VERSION}/gcc_64/lib/libQt5WebEngineCore.so.${QT_VERSION}

du -sh ./5*

#$(go env GOPATH)/bin/qtsetup
