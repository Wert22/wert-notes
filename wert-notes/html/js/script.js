var currentId = undefined;

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                $("#ana").css('display', 'inline-block');
                break;
            case "load":
                currentId = event.data.id;
                document.getElementById("p1").value = event.data.text;
                $("#ana").css('display', 'inline-block');
                break;
            case "close":
                $("#ana").css('display', 'none');
                currentId = undefined;
                document.getElementById("p1").value = "";
                break;
        }
    })
});

document.onkeyup = function (data) {
    if (data.which == 27) {
        close();
    }
};

function close() {
    currentId = undefined;
    $("#ana").css('display', 'none');
    document.getElementById("p1").value = "";
    $.post('https://wert-notes/close', JSON.stringify({}));
}

function closeevent() {
    currentId = undefined;
    $("#ana").css('display', 'none');
    document.getElementById("p1").value = "";
    $.post('https://wert-notes/close', JSON.stringify({}));
}

function saveevent() {
    var yazi = document.getElementById("p1").value;
    if (yazi != "") {
        if (currentId != undefined) {
            $.post('https://wert-notes/save-note', JSON.stringify({id: currentId, text: yazi}));
        } else {
            $.post('https://wert-notes/new-note', JSON.stringify({text: yazi}));
        }
    } else {
        $.post('https://wert-notes/notify', JSON.stringify({notif: "Boş sayfa kayıt edemezsin!"}));
    }
}

function deleteevent() {
    if (currentId != undefined) {
        $.post('https://wert-notes/delete-note', JSON.stringify({id: currentId}));
    } else {
        $.post('https://wert-notes/notify', JSON.stringify({notif: "Bu sayfayı yırtıp atamazsın!"}));
    }
}

function shareevent() {
    var yazi = document.getElementById("p1").value;
    if (currentId != undefined) {
        $.post('https://wert-notes/share-note', JSON.stringify({id: currentId, text: yazi}));
    } else {
        $.post('https://wert-notes/notify', JSON.stringify({notif: "Bu sayfayı paylaşamazsın!"}));
    }
}
