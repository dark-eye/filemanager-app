SOURCES += $$PWD/dirmodel.cpp \
           $$PWD/iorequest.cpp \
           $$PWD/iorequestworker.cpp \
           $$PWD/ioworkerthread.cpp \
           $$PWD/filesystemaction.cpp \
           $$PWD/filecompare.cpp \
           $$PWD/externalfswatcher.cpp \
           $$PWD/clipboard.cpp \
           $$PWD/fmutil.cpp \
           $$PWD/dirselection.cpp \
           $$PWD/diriteminfo.cpp \
           $$PWD/trash/qtrashdir.cpp


HEADERS += $$PWD/dirmodel.h \
           $$PWD/iorequest.h \
           $$PWD/iorequestworker.h \
           $$PWD/ioworkerthread.h \
           $$PWD/filesystemaction.h \
           $$PWD/filecompare.h \
           $$PWD/externalfswatcher.h \
           $$PWD/clipboard.h \
           $$PWD/fmutil.h  \
           $$PWD/dirselection.h \          
           $$PWD/diritemabstractlistmodel.h \
           $$PWD/diriteminfo.h \
           $$PWD/trash/qtrashdir.h


INCLUDEPATH  += $$PWD $$PWD/trash

greaterThan(QT_MAJOR_VERSION, 4) {
   QT += qml
}
else {
    QT += declarative    
}


!contains (DEFINES, DO_NOT_USE_TAG_LIB) {
   LIBS += -ltag
   SOURCES += $$PWD/imageprovider.cpp 
   HEADERS += $$PWD/imageprovider.h 
}