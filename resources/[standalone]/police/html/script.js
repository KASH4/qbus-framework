const CameraApp = new Vue({
    el: "#camcontainer",

    data: {
        camerasOpen: false,
        cameraLabel: ":)",
        connectLabel: "CONNECTED",
        ipLabel: "192.168.0.1",
        dateLabel: "04/09/1999",
        timeLabel: "16:27:49",
    },

    methods: {
        OpenCameras(label, connected, cameraId, time) {
            var today = new Date();
            var date = today.getDate()+'/'+(today.getMonth()+1)+'/'+today.getFullYear();
            var formatTime = "00:" + time

            this.camerasOpen = true;
            this.ipLabel = "145.101.0."+cameraId;
            if (connected) {
                $("#blockscreen").css("display", "none");
                this.cameraLabel = label;
                this.connectLabel = "CONNECTED";
                this.dateLabel = date;
                this.timeLabel = formatTime;

                $("#connectedlabel").removeClass("disconnect");
                $("#connectedlabel").addClass("connect");
            } else {
                $("#blockscreen").css("display", "block");
                this.cameraLabel = "ERROR #400: BAD REQUEST"
                this.connectLabel = "CONNECTION FAILED";
                this.dateLabel = "ERROR";
                this.timeLabel = "ERROR";

                $("#connectedlabel").removeClass("connect");
                $("#connectedlabel").addClass("disconnect");
            }
            
        },

        CloseCameras() {
            this.camerasOpen = false;
            $("#blockscreen").css("display", "none");
        },

        UpdateCameraLabel(label) {
            this.cameraLabel = label;
        },

        UpdateCameraTime(time) {
            var formatTime = "00:" + time
            this.timeLabel = formatTime;
        },
    }
});

HeliCam = {}

HeliCam.Open = function(data) {
    $("#helicontainer").css("display", "block");
    $(".scanBar").css("height", "0%");
}

HeliCam.UpdateScan = function(data) {
    $(".scanBar").css("height", data.scanvalue +"%");
}

HeliCam.UpdateVehicleInfo = function(data) {
    $(".vehicleinfo").css("display", "block");
    $(".scanBar").css("height", "100%");
    $(".heli-model").find("p").html("MODEL: " + data.model);
    $(".heli-plate").find("p").html("PLATE: " + data.plate);
    $(".heli-street").find("p").html(data.street);
    $(".heli-speed").find("p").html(data.speed + " KM/U");
}

HeliCam.DisableVehicleInfo = function() {
    $(".vehicleinfo").css("display", "none");
}

HeliCam.Close = function() {
    $("#helicontainer").css("display", "none");
    $(".vehicleinfo").css("display", "none");
    $(".scanBar").css("height", "0%");
}

document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function(event) {

            if (event.data.type == "enablecam") {
                CameraApp.OpenCameras(event.data.label, event.data.connected, event.data.id, event.data.time);
            } else if (event.data.type == "disablecam") {
                CameraApp.CloseCameras();
            } else if (event.data.type == "updatecam") {
                CameraApp.UpdateCameraLabel(event.data.label);
            } else if (event.data.type == "updatecamtime") {
                CameraApp.UpdateCameraTime(event.data.time);
            } else if (event.data.type == "heliopen") {
                HeliCam.Open(event.data);
            } else if (event.data.type == "heliclose") {
                HeliCam.Close();
            } else if (event.data.type == "heliscan") {
                HeliCam.UpdateScan(event.data);
            } else if (event.data.type == "heliupdateinfo") {
                HeliCam.UpdateVehicleInfo(event.data);
            } else if (event.data.type == "disablescan") {
                HeliCam.DisableVehicleInfo();
            }

        });
    };
};