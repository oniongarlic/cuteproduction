import QtQuick

ListModel {

    property int currentIndex: -1

    function addItem(src) {
        var o={'source':src}
        let m=fr.getMetaData(src);
        o['duration']=m.duration
        append(o)
    }

    function addItems(srcs) {
        for (var i=0;i<srcs.length;i++) {
            addItem(srcs[j])
        }
    }

    function next() {
        if (currentIndex<count)
            currentIndex++
    }

    function previous() {
        if (currentIndex>count)
            currentIndex--
    }

    onCurrentIndexChanged: {

    }

}

