qbPhone = {}

var inPhone = false;
var phoneApps = null;
var allowNotifys = null;
var myNotify = false;
var currentApp = ".phone-home-page";
var homePage = ".phone-home-page";
var lastPage = null;
var choosingBg = false;
var curBg = "bg-1";
var selectedContact = null;

var currentMailEvent = null;
var currentMailData = null;
var mailId = null;

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            qbPhone.Close();
            break;
    }
});

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();

    console.log('QB Phone\'s javascript has succesfully loaded, no errors occured..')

    window.addEventListener('message', function(event){
        var eventData = event.data;

        if (eventData.action = "phone") {
            if (!eventData.task) {
                if (eventData.open == true) {
                    qbPhone.Open()
                    qbPhone.setupPhoneApps(eventData.apps)
                } else if (eventData.open == false) {
                    qbPhone.Close()
                }
            }
        }

        if (eventData.task == "setPhoneMeta") {
            qbPhone.setPhoneMeta(eventData.pMeta, eventData.pData.charinfo.phone);
        }

        if (eventData.task == "setUserContacts") {
            qbPhone.setupPlayerContactInfo(eventData.pData.charinfo.firstname, eventData.pData.charinfo.lastname, eventData.pData.charinfo.phone);
            qbPhone.setupPlayerContacts(eventData.pContacts);
        }

        if (eventData.task == "setupBankData") {
            qbPhone.setBankData(eventData.pData)
        }

        if (eventData.task == "updateTime") {
            qbPhone.updateTime(eventData.time)
        }

        if (eventData.task == "getVehicles") {
            qbPhone.setGarageVehicles(eventData.vehicles)
        }

        if (eventData.task == "setupMail") {
            qbPhone.setupUserMails(eventData.mails)
        }

        if (eventData.task == "newMailNotify") {
            console.log('dsgsdgds')
            qbPhone.MailNotify()
        }

        if (eventData.task == "setupTweets") {
            qbPhone.SetupTweets(eventData.tweets);
        }

        if (eventData.task == "newTweetNotify") {
            qbPhone.TwitterNotify(eventData.sender)
        }

        if (eventData.task == "newTweet") {
            qbPhone.SetupTweets(eventData.tweets);
            qbPhone.Notify('<i class="fab fa-twitter" style="position: relative; padding-top: 3px;"></i> Twitter', 'tweet', '@'+eventData.sender + ' heeft een tweet geplaatst!')
        }
    });

    $('.notify-btn').change(function() {
        if (allowNotifys == null) {
            if (myNotify) {
                allowNotifys = true;
                qbPhone.toggleNotify(true)
            } else {
                allowNotifys = false;
                qbPhone.toggleNotify(false)
            }
        } else {
            if (!allowNotifys) {
                allowNotifys = true;
                qbPhone.toggleNotify(true)
            } else {
                allowNotifys = false;
                qbPhone.toggleNotify(false)
            }
        }
    })
});

$(document).on('click', '.app', function(e){
    e.preventDefault();

    var appId = $(this).attr('id');
    var pressedApp = $('#'+appId).data('appData');

    $("."+pressedApp.app+"-app").css({'display':'block'}).animate({
        top: "3%",
    }, 250);

    currentApp = "."+pressedApp.app+"-app";

    if (pressedApp.app == "contacts") {
        $.post('http://qb-phone/setupContacts');
    } else if (pressedApp.app == "bank") {
        $.post('http://qb-phone/getBankData');
    } else if (pressedApp.app == "garage") {
        $.post('http://qb-phone/getVehicles');
    } else if (pressedApp.app == "mails") {
        $.post('http://qb-phone/getUserMails');
    } else if (pressedApp.app == "twitter") {
        $.post('http://qb-phone/getTweets');
    }

    qbPhone.succesSound();
});

$(document).on('click', '#chat-window-arrow-left', function(e){
    e.preventDefault();

    $('.chat-window').css({"display":"block"}).animate({top: "103.5%",}, 250, function(){
        $(".chat-window").css({"display":"none"});
    });
})

$(document).on('click', '.chat', function(e){
    e.preventDefault();

    $('.chat-window').css({"display":"block"}).animate({top: "3%",}, 250);
    qbPhone.loadUserMessages();
});

$(document).on('click', '#background-item', function(e){
    e.preventDefault();

    $('.background-block').css({"display":"block"}).animate({top: "20%",}, 250);
    setTimeout(function(){
        choosingBg = true;
    }, 100)
    qbPhone.succesSound();
});

$(document).on('click', '.add-contact-btn', function(e){
    e.preventDefault();

    $('.add-contact-container').css({"display":"block"}).animate({top: "20%",}, 250);
    setTimeout(function(){
        $(".contactname-input").val("");
        $(".number-input").val("");
        addingContact = true;
    }, 100)
    qbPhone.succesSound();
});

$(document).on('click', '.submit-contact-btn', function(e){
    var contactName = $(".contactname-input").val();
    var contactNum = $(".number-input").val();

    if(contactName != "" || contactNum != "") {
        if (!isNaN(contactNum)) {
            $('.add-contact-container').css({"display":"block"}).animate({top: "103%",}, 250);
            qbPhone.Notify('Contacten', 'success', contactName+" ("+contactNum+") is toegevoegd aan je contacten.")
            $.post('http://qb-phone/addToContact', JSON.stringify({
                contactName: contactName,
                contactNum: contactNum
            }))
        } else {
            qbPhone.Notify('Contacten', 'error', 'Het telefoon nummer moet bestaan uit cijfers.')
        }
    } else {
        qbPhone.Notify('Contacten', 'error', 'Je hebt niet alle contactgegevens ingevuld.')
    }
});

$(document).on('click', '.back-contact-btn', function(e){
    $('.add-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $(".add-contact-container").css({"display":"none"});
    });
});

$(document).on('click', '.back-transfer-btn', function(e){
    $('.transfer-money-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $('.transfer-money-container').css({'display':'none'});
    });
});

$(document).on('click', '.bank-transfer-btn', function(e){
    $('.transfer-money-container').css({"display":"block"}).animate({top: "25.5%",}, 250);
});

$(document).on('click', '.submit-transfer-btn', function(e){
    var ibanVal = $(".iban-input").val();
    var amountVal = $(".euro-amount-input").val();
    var balance = $("#balance").val();

    if (ibanVal != "" && amountVal != "") {
        if (!isNaN(amountVal)) {
            if (balance - amountVal < 0) {
                qbPhone.Notify('Maze Bank', 'error', 'Je hebt niet genoeg saldo', 3500)
            } else {
                $('.transfer-money-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
                    $('.transfer-money-container').css({'display':'none'});
                    qbPhone.Notify('Maze Bank', 'success', 'Je hebt € '+amountVal+' overgemaakt naar '+ibanVal+'!', 3500)

                    $.post('http://qb-phone/transferMoney', JSON.stringify({
                        amount: amountVal,
                        iban: ibanVal
                    }))
                });
            }
        } else {
            qbPhone.Notify('Maze Bank', 'error', 'De hoeveelheid moet bestaan uit cijfers.', 3500)
        }
    } else {
        qbPhone.Notify('Maze Bank', 'error', 'Je hebt niet alle gegevens ingevuld.', 3500)
    }
});

$(document).on('click', '.settings-app', function(e){
    if (choosingBg) {
        $('.background-block').animate({top: "100%",}, 
        250, function(){
            $('.background-block').css({'display':'none'});
            choosingBg = false;
        });
    }
});

$(document).on('click', '.background-option', function(e){
    e.preventDefault();

    var selectedBackground = $(this).attr('id');
    $(".phone-home-page").css("background-image", "url(./img/"+selectedBackground+".png)");
    $("#"+curBg).removeClass("selected-bg");
    $(this).addClass("selected-bg");
    curBg = $(this).attr("id");

    if (curBg == "bg-1") {
        $("#current-background").html("Gradient Green");
    } else if (curBg == "bg-2") {
        $("#current-background").html("Abstract");
    }
    $.post('http://qb-phone/setPlayersBackground', JSON.stringify({
        background: selectedBackground
    }))
    qbPhone.succesSound();
});

$(document).on('click', '.home-container', function(e){
    e.preventDefault();

    console.log(currentApp)

    if (lastPage == null) {
        if (currentApp != homePage) {
            $(currentApp).animate({top: "100%",}
            , 250, function() {
                $(currentApp).css({'display':'none'});
                $(homePage).css({'display':'block'});
                currentApp = homePage;
            });
    
            qbPhone.succesSound();
        } else {
            qbPhone.Close();
        }
    } else {
        $(currentApp).animate({top: "100%",}
        , 250, function() {
            $(currentApp).css({'display':'none'});
            $(lastPage).css({'display':'block'});
            currentApp = lastPage;
            lastPage = null;
        });

        buttonEvent = null
        buttonData = null
        mailId = null
    
        qbPhone.succesSound();
    }
});

qbPhone.Open = function() {
    inPhone = true;
    $(homePage).css({'display':'block'})
    $('.phone-container').css({'display':'block'}).animate({
        top: "41.3%",
    }, 300);
    $('.phone-frame').css({'display':'block'}).animate({
        top: "40%",
    }, 300);
    qbPhone.Log('Phone opened');
}

qbPhone.Close = function() {
    inPhone = false;
    $('.phone-container').css({'display':'block'}).animate({
        top: "100%",
    }, 300);
    $('.phone-frame').css({'display':'block'}).animate({
        top: "100%",
    }, 300, function(){
        if (currentApp == ".opened-mail") {
            $(currentApp).animate({top: "100%",}, 250, function() {
                $(currentApp).css({'display':'none'});
            });
            $(".mails-app").animate({top: "100%",}, 250, function() {
                $(".mails-app").css({'display':'none'});
                $(homePage).css({'display':'block'});
                currentApp = homePage;
            });
        } else {
            if (currentApp != homePage) {
                $(currentApp).animate({top: "100%",}
                , 250, function() {
                    $(currentApp).css({'display':'none'});
                    $(homePage).css({'display':'block'});
                    currentApp = homePage;
                });
            } 
        }
    });
    $.post('http://qb-phone/closePhone');
    qbPhone.Log('Phone closed');
}

qbPhone.setupPhoneApps = function(apps) {
    if (phoneApps === null) {
        $.each(apps, function(index, app) {
            $('.slot-'+app.slot).html("");
            var appElement = '<div class="app" id="slot-'+app.slot+'" style="background-color: '+app.color+';" data-toggle="tooltip" data-placement="bottom" title="'+app.tooltipText+'"><i class="'+app.icon+'" id="app-icon" style="'+app.style+'"></i></div>'
            $('.slot-'+app.slot).append(appElement);
            $('.slot-'+app.slot).removeClass("empty-slot");
            $('#slot-'+app.slot).data('appData', app);
        });
        qbPhone.Log('Phone apps have been generated');
        $('[data-toggle="tooltip"]').tooltip();
    }
    phoneApps = apps
}

qbPhone.Log = function(log) {
    console.log(log)
}

qbPhone.toggleNotify = function(bool) {
    allowNotifys = bool;
    if (bool) {
        $(".notify-state").html("Aan");
    } else {
        $(".notify-state").html("Uit");
    }

    $.post('http://qb-phone/setNotifications', JSON.stringify({allow: bool}));
    qbPhone.succesSound();
}

qbPhone.succesSound = function() {
    $.post('http://qb-phone/succesSound');
}

qbPhone.errorSound = function() {
    $.post('http://qb-phone/errorSound');
}

qbPhone.setPhoneMeta = function(phoneMeta, phoneNumber) {
    qbPhone.setPlayersNotification(phoneMeta.settings.notification)
    qbPhone.setPlayersBackground(phoneMeta.settings.background)
    qbPhone.setPlayersPhoneNumber(phoneNumber)
}

qbPhone.setPlayersNotification = function(allow) {
    myNotify = allow;
    if (allow) {
        $("#notification-toggle").bootstrapToggle('on')
    } else {
        $("#notification-toggle").bootstrapToggle('off')
    }
}

qbPhone.setPlayersPhoneNumber = function(num) {
    $('.phone-num').html(num);
}

qbPhone.setPlayersBackground = function(background) {
    $(".phone-home-page").css("background-image", "url(./img/"+background+".png)");
    $("#"+background).addClass("selected-bg");
    curBg = background;
    $("#current-background").html("Gradient Green");
    if (background == "bg-1") {
        $("#current-background").html("Gradient Green");
    } else if (background == "bg-2") {
        $("#current-background").html("Abstract");
    }
}

qbPhone.updateTime = function(time) {
    $("#time").html(time.hour+"."+time.minute);
}

qbPhone.setupPlayerContactInfo = function(firstName, lastName, phoneNumber) {
    $("#firstletters").html((firstName).charAt(0).toUpperCase()+""+(lastName).charAt(0).toUpperCase());
    $("#myi-number").html(phoneNumber);
}

var editContactData = null;

$(document).on('click', '.edit-contact', function(e){
    e.preventDefault();

    var cId = $(this).attr('id');
    var contactData = $("#"+cId).data('cData');

    $('.edit-contact-container').css({"display":"block"}).animate({top: "20%",}, 250);
    editContactData = contactData;
    setTimeout(function(){
        $(".edit-contactname-input").val(contactData.name);
        $(".edit-number-input").val(contactData.number);
    }, 100)
    qbPhone.succesSound();
})

$(document).on('click', '.back-edit-contact-btn', function(e){
    $('.edit-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $(".edit-contact-container").css({"display":"none"});
    });

    editContactData = null;
});

$(document).on('click', '.change-contact-btn', function(e){
    var oldContactName = editContactData.name;
    var oldContactNum =  editContactData.number;

    if($(".edit-number-input").val() != "" || $(".edit-contactname-input").val() != "") {
        if (!isNaN($(".edit-number-input").val())) {
            $.post('http://qb-phone/editContact', JSON.stringify({
                oldContactName: oldContactName,
                oldContactNum: oldContactNum,
                newContactName: $(".edit-contactname-input").val(),
                newContactNum: $(".edit-number-input").val(),
            }))
            qbPhone.Notify('Contacten', 'success', 'Contact opgeslagen');
            $('.edit-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
                $(".edit-contact-container").css({"display":"none"});
            });
        } else {
            qbPhone.Notify('Contacten', 'error', 'Het telefoon nummer moet bestaan uit cijfers.')
        }
    } else {
        qbPhone.Notify('Contacten', 'error', 'Je hebt niet alle contactgegevens ingevuld.')
    }

    editContactData = null;
});

function changecName() {
    var currentVal = $(".contactname-input").val();

    $(".contactname-input").val(currentVal);
}

$(document).on('click', '.delete-contact-btn', function(e){
    $('.edit-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $(".edit-contact-container").css({"display":"none"});
    });

    editContactData = null;
});

qbPhone.setupPlayerContacts = function(contacts) {
    $(".contact-list").html("");
    $.each(contacts, function(index, contact){
        var contactHTML = '<div class="contact"><div class="contact-status" id="contact-'+index+'"></div><div class="contact-options">' +
        '<div class="contact-option call-contact" id="cData-'+index+'"><i class="fa fa-phone" id="call-contact-icon"></i></div>' +
        '<div class="contact-option sms-contact" id="cData-'+index+'"><i class="fa fa-sms" id="sms-contact-icon"></i></div>' +
        '<div class="contact-option edit-contact" id="cData-'+index+'"><i class="fa fa-edit" id="edit-contact-icon"></i></div></div>' +
        '<span id="contact-name">'+contact.name+'</span></div>'
        $(".contact-list").append(contactHTML);
        if (contact.status === "unknown") {
            $("#contact-"+index).addClass("unknown");
        } else if (contact.status === true) {
            $("#contact-"+index).addClass("online");
        } else if (contact.status === false) {
            $("#contact-"+index).addClass("offline");
        }

        console.log(contact.status)
        $("#contact-"+index).data("contactData", contact);
        $("#cData-"+index).data("cData", contact);
    });
}

var timeout = null;

qbPhone.Notify = function(title, type, message, wait) {
    if (allowNotifys) {
        if (timeout != undefined) {
            clearTimeout(timeout);
        }
        $('.phone-notify').css({'display':'block', 'top':'-10%'})
        if (type == 'error') {
            $("#notify-titel").css("color", "rgb(126, 9, 9);");
        } else if (type == 'success') {
            $("#notify-titel").css("color", "rgb(9, 126, 9);");
        } else if (type == 'tweet') {
            $("#notify-titel").css("color", "rgb(29, 161, 242);");
        }
        $("#notify-titel").html(title);
        $("#notify-message").html(message);
        $('.phone-notify').css({'display':'block'}).animate({
            top: "5%",
        }, 300);
        if (wait == null) {
            timeout = setTimeout(function(){
                $('.phone-notify').css({'display':'block'}).animate({
                    top: "-10%",
                }, 300, function(){
                    $('.phone-notify').css({'display':'none'})
                });
            }, 3500)
        } else {
            timeout = setTimeout(function(){
                $('.phone-notify').css({'display':'block'}).animate({
                    top: "-10%",
                }, 300, function(){
                    $('.phone-notify').css({'display':'none'})
                });
            }, wait)
        }
    }
}

qbPhone.setBankData = function(playerData) {
    $(".welcome-title").html("<p>Hallo, "+playerData.charinfo.firstname+" "+playerData.charinfo.lastname+"!</p>");
    $("#balance").html(playerData.money.bank);
    $("#balance").val(playerData.money.bank);
    $("#iban").html(playerData.charinfo.account);
}

qbPhone.setGarageVehicles = function(vehicles) {
    console.log('yeet?')
    $(".garage-vehicles").html("");
    $.each(vehicles, function(index, vehicle){
        var element = '<div class="garage-vehicle"> '+
        '<div class="garage-vehicle-image" style="background-image: url('+vehicle.image+');"></div>' +
            '<div class="garage-vehicle-name"><p><i class="fas fa-car" id="car-icon"></i> '+vehicle.name+'</p></div>' +
            '<div class="garage-vehicle-garage"><p><i class="fas fa-warehouse" id="warehouse-icon"></i> '+vehicle.garage+'</p></div>' +
            '<div class="garage-vehicle-state"><p><i class="fas fa-parking" id="parking-icon"></i> '+vehicle.state+'</p></div>' +
            '<div class="garage-vehicle-stats"><span id="vehicle-engine"><i class="fas fa-shield-alt" id="body-icon"></i> '+(vehicle.body / 10)+'%  |  </span><span id="vehicle-body"><i class="fas fa-car-battery" id="battery-icon"></i> '+(vehicle.engine / 10)+'%  |  </span><span id="vehicle-fuel"><i class="fas fa-gas-pump" id="fuel-icon"></i> '+(vehicle.fuel / 10)+'%</span></div>' +
        '</div>';

        $(".garage-vehicles").append(element);
    });
}

qbPhone.loadUserMessages = function() {
    var messageScreen = $('.messages');
    var height = messageScreen[0].scrollHeight;
    messageScreen.scrollTop(height);
}

qbPhone.setupUserMails = function(mails) {
    $('.mails-list').html("");
    if (mails != undefined) {
        $.each(mails, function(i, mail){
            if (mail.read == 0) {
                var element = '<div class="mail" id="mail-'+i+'"><div class="mail-sender-dot"></div><span id="mail-sender-name">'+mail.sender+'</span><span id="mail-id">#'+mail.mailid+'</span><span id="mail-subject">'+mail.subject+'</span><span id="mail-message">'+mail.message+'</span></div>';
            } else {
                var element = '<div class="mail" id="mail-'+i+'"><span id="mail-sender-name">'+mail.sender+'</span><span id="mail-id">#'+mail.mailid+'</span><span id="mail-subject">'+mail.subject+'</span><span id="mail-message">'+mail.message+'</span></div>';
            }

            $('.mails-list').append(element);
    
            $('#mail-'+i).data('mailData', mail)
        });
    } else {
        $(".mails-list").html('<span id="no-emails-error">Je inbox is leeg</span>')
    }
}

$(document).on('click', '.mail', function(){
    var curMid = $(this).attr('id');
    var mailData = $('#'+curMid).data('mailData');
    qbPhone.openMail(mailData)
});

$(document).on('click', '.mail-button', function(){
    $.post('http://qb-phone/clickMailButton', JSON.stringify({
        buttonEvent: currentMailEvent,
        buttonData: currentMailData,
        mailId: currentMailId,
    }))

    buttonEvent = null
    buttonData = null
    mailId = null

    qbPhone.Close();
});

$(document).on('click', '#opened-mail-delete-icon', function(){
    $.post('http://qb-phone/removeMail', JSON.stringify({
        mailId: currentMailId
    }))

    $(currentApp).animate({top: "100%",}
    , 250, function() {
        $(currentApp).css({'display':'none'});
        $(lastPage).css({'display':'block'});
        currentApp = lastPage;
        lastPage = null;
    });

    buttonEvent = null
    buttonData = null
    mailId = null

    $.post('http://qb-phone/getUserMails');
});

qbPhone.openMail = function(mailData) {

    var element

    if (mailData.button != undefined) {
        if (mailData.button.enabled) {
            currentMailEvent = mailData.button.buttonEvent;
            currentMailData = mailData.button.buttonData;
            element = '<div class="opened-mail-header"><p>Zender: '+mailData.sender+'</p><p> <span id="opened-mail-subject">Onderwerp: '+mailData.subject+'</span></p><i class="material-icons" id="opened-mail-delete-icon">delete</i></div>' +
            '<div class="opened-mail-content">' +
            '    <p>'+mailData.message+'</p><div class="mail-button"><p>Accepteren</p></div>' +
            '</div>';
        } else {
            element = '<div class="opened-mail-header"><p>Zender: '+mailData.sender+'</p><p> <span id="opened-mail-subject">Onderwerp: '+mailData.subject+'</span></p><i class="material-icons" id="opened-mail-delete-icon">delete</i></div>' +
            '<div class="opened-mail-content">' +
            '    <p>'+mailData.message+'</p>' +
            '</div>';
        }
    } else {
        element = '<div class="opened-mail-header"><p>Zender: '+mailData.sender+'</p><p> <span id="opened-mail-subject">Onderwerp: '+mailData.subject+'</span></p><i class="material-icons" id="opened-mail-delete-icon">delete</i></div>' +
        '<div class="opened-mail-content">' +
        '    <p>'+mailData.message+'</p>' +
        '</div>';
    }

    currentMailId = mailData.mailid;

    $(".opened-mail").html(element);

    if (mailData.read == 0) {
        $.post('http://qb-phone/setEmailRead', JSON.stringify({
            mailId: mailData.mailid
        }));
    }

    $(".opened-mail").css({'display':'block'}).animate({
        top: "3%",
    }, 250);

    currentApp = ".opened-mail";
    lastPage = ".mails-app";
}

$(document).on('click', '.twitter-new-tweet', function(){
    $('.twitter-app-new-tweet').css({'display':'block'}).animate({
        bottom: "17vh"
    }, 200);
});

$(document).on('click', '.send-new-tweet', function(){
    var tweetMessage = $('#new-tweet-message').val();

    if (tweetMessage != "") {
        $('.twitter-app-new-tweet').css({'display':'block'}).animate({
            bottom: "-27vh"
        }, 200);
        $.post('http://qb-phone/postTweet', JSON.stringify({
            message: tweetMessage
        }))
    } else {
        qbPhone.Notify('Twitter', 'error', 'Je kan geen legen tweet versturen...')
    }
});

$(document).on('click', '.cancel-new-tweet', function(){
    $('.twitter-app-new-tweet').css({'display':'block'}).animate({
        bottom: "-27vh"
    }, 200);
});

qbPhone.MailNotify = function() {
    $(".new-mail-notify").css({'display':'block'}).animate({
        top: "0%",
    }, 500);
    setTimeout(function(){
        $(".new-mail-notify").css({'display':'block'}).animate({
            top: "-10%",
        }, 250)
    }, 2500)
}

qbPhone.TwitterNotify = function(sender) {
    $('.new-twitter-notify-content'),html("@" + sender + " heeft een nieuwe tweet geplaatst!");
    $(".new-twitter-notify").css({'display':'block'}).animate({
        top: "0%",
    }, 500);
    setTimeout(function(){
        $(".new-twitter-notify").css({'display':'block'}).animate({
            top: "-10%",
        }, 250)
    }, 2500)
}

qbPhone.SetupTweets = function(tweets) {
    $('.twitter-tweets').html("");
    if (tweets != undefined) {
        $.each(tweets, function(i, tweet){
            var elem = '<div class="twitter-app-tweet"><img src="./img/anonymous-person-icon-0.jpg" alt="anonymous-person-icon-0" class="tweeter-image"><div class="tweet-name"><span id="tweeter-name">'+tweet.sender+'</span> <span id="tweeter-ad">@'+tweet.sender+'</span></div><div class="tweeter-message"><p>'+tweet.message+'</p></div></div>';
    
            $('.twitter-tweets').append(elem);
        });
    } else {
        $(".twitter-tweets").html('<span id="no-emails-error">Er zijn nog<br> geen Tweets geplaatst :(</span>')
    }
}

updateNewBalance = function() {
    var balance = $("#balance").val();
    var minAmount = $(".euro-amount-input").val();
    $("#new-balance").html(balance - minAmount);
    console.log(balance)
}

// qbPhone.Open();