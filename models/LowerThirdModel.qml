import QtQuick 

ListModel {
    id: l3model
    
    function toJSON() {
        var o = []
        for (var j = 0; j < count; j++) {
            o[j]=get(j)
        }
        return JSON.stringify(o)
    }
    function fromJSON(str) {
        try {
            var o = JSON.parse(str)
            if (!Array.isArray(o)) {
                  throw new Error("Parsed data is not an array.");
                }
            l3ModelFinal.clear()
            o.forEach((item, index) => {
                l3ModelFinal.append(item)
            });
        } catch (e) {
            console.debug(e)
            return false;
        }
        console.debug("*** JSON loaded ok", count)
        return true;
    }
}
