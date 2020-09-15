<template>
<v-app>
    <v-app-bar app color="black" dark>
        <v-btn text>
            <v-icon dark>mdi-room-service</v-icon>
        </v-btn>
        <v-toolbar-title>Community</v-toolbar-title>
    </v-app-bar>
    <v-main>
        <template>
            <v-card>
                <v-tabs background-color="white" color="black" right>
                    <v-tab>Report</v-tab>
                    <v-tab>View Complaints</v-tab>
                    <v-tab>Map</v-tab>
                    <v-tab-item key="1">
                        <v-container fluid>
                            <v-row>
                                <v-col cols="12">
                                    <v-form ref="form" v-model="valid" lazy-validation>
                                        <v-text-field v-model="title" counter :rules="titleRules" label="Report Title" required></v-text-field>
                                        <v-textarea v-model="description" solo name=" input-7-4" label="Description" counter></v-textarea>
                                        <v-file-input v-model="files" color="black" counter label="Images" multiple placeholder="Upload Pictures" prepend-icon="mdi-paperclip" outlined :show-size="1000">
                                            <template v-slot:selection="{ index, text }">
                                                <v-chip v-if="index < 2" color="black" dark label small>{{ text }}</v-chip>

                                                <span v-else-if="index === 2" class="overline grey--text text--darken-3 mx-2">+{{ files.length - 2 }} File(s)</span>
                                            </template>
                                        </v-file-input>
                                        <v-btn color="white" class="mr-4" @click="getLocation">Get Location</v-btn>
                                        <v-btn :disabled="
                          !valid && files.length === 0 && location !== ''
                        " color=" white" class="mr-4" @click="startUpload">Submit</v-btn>
                                    </v-form>
                                </v-col>
                            </v-row>
                        </v-container>
                    </v-tab-item>
                    <v-tab-item key="2">
                        <v-container fluid>
                            <v-row>
                                <v-col v-for="(report, i) in $store.state.reports" :key="i" cols="12" md="4">
                                    <template>
                                        <v-card class="mx-auto" max-width="400">
                                            <v-img lazy-src="https://picsum.photos/id/11/100/60" aspect-ratio="1" class="grey lighten-2" max-width="500" max-height="300" :src="report.src"><template v-slot:placeholder>
                                                    <v-row class="fill-height ma-0" align="center" justify="center">
                                                        <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
                                                    </v-row>
                                                </template>
                                            </v-img>
                                            <v-card-text class="text--primary">
                                                <div>{{ report.title }}</div>
                                                <div>{{ report.description }}</div>
                                                <v-switch :v-model="report.resolved" label="Resolved" disabled></v-switch>
                                            </v-card-text>
                                            <v-card-actions>
                                                <v-btn color="orange" @click="goto(report.receipt)" text>View Receipt</v-btn>
                                                <v-btn v-if="report.resolved" color="orange" @click="goto(report.receipt)" text>Details</v-btn>
                                                <v-btn color="orange" @click="openMaps(report.location)" text>View on Map</v-btn>
                                            </v-card-actions>
                                        </v-card>
                                    </template>
                                </v-col>
                            </v-row>
                        </v-container>
                    </v-tab-item>
                    <v-tab-item key="3">
                        <v-container fluid>
                            <v-card flat>
                                <v-card-text>Still in development</v-card-text>
                            </v-card>
                        </v-container>
                    </v-tab-item>
                </v-tabs>
            </v-card>
        </template>
        <loading :active.sync="isLoading" :is-full-page="true" />
    </v-main>
</v-app>
</template>

<script>
import Loading from "vue-loading-overlay";
// Import stylesheet
import "vue-loading-overlay/dist/vue-loading.css";
import axios from "axios";
import swal from "sweetalert2";

export default {
    name: "Community",

    components: {
        Loading,
    },
    data: () => ({
        repo: {},
        db: {},
        orbitdb: {},
        communityContract: require("../../../embarkArtifacts/contracts/Community")
            .default,
        isLoading: false,
        files: [],
        valid: true,
        fileRules: [
            (value) =>
            !value ||
            value.size < 10000000000 ||
            "Avatar size should be less than 100 MB!",
        ],
        title: "",
        titleRules: [
            (v) => !!v || "Title is required",
            (v) =>
            (v && v.length >= 4) ||
            "Title must be greater than equal to 4 characters",
        ],
        description: "",
        descriptioRules: [
            (v) => !!v || "Description is required",
            (v) =>
            (v && v.length >= 5) ||
            "Description must be greater than equal to 20 characters",
        ],
        emailRules: [
            (v) => !!v || "E-mail is required",
            (v) => /.+@.+\..+/.test(v) || "E-mail must be valid",
        ],
        select: null,
        items: ["Item 1", "Item 2", "Item 3", "Item 4"],
        checkbox: false,
        location: "",
    }),
    mounted() {
        this.loadReports();
        // this.createDB();
    },
    methods: {
        createDB: async function () {
            var test = require('../../');
            const IpfsClient = require("ipfs-http-client");
            const OrbitDB = require("orbit-db");
            const ipfs = IpfsClient({
                host: "localhost",
                port: 5001,
                protocol: "http",
            });

            const orbitdb = await OrbitDB.createInstance(ipfs);
            this.db = await orbitdb.keyvalue("community");
            await this.db.load();
            if (this.db.get("mainDB")) {
                this.repo = JSON.parse(this.db.get("mainDB"));
                console.log('this.db.get("mainDB"): ', this.db.get("mainDB"));
            } else {
                const hash = this.db
                    .put(
                        "mainDB",
                        JSON.stringify({
                            reports: [],
                            resolved: [],
                        })
                    )
                    .then(() => {
                        console.log("mainDB: ", this.db.get("mainDB"));
                        // 100
                    });
                console.log(hash);
            }

            this.db.events.on("replicated", (address) => {
                console.log(
                    this.db
                    .iterator({
                        limit: -1,
                    })
                    .collect()
                );
            });
        },
        goto(link) {
            console.log("going to: ", link);
            var win = window.open(link, "_blank");
            win.focus();
        },
        openMaps(geo) {
            var url =
                "http://www.google.com/maps/place/" + geo.lat + "," + geo.longtitude;
            console.log("navigating to url: ", geo);

            var inAppBrowser = window.open(url, "_blank", "location=yes");
        },
        loadReports: async function () {
            this.isLoading = true;
            this.$store.state.reports = [];
            var reportedKeys = await this.communityContract.methods
                .getReportKeys()
                .call();
            console.log("reportedKeys: ", reportedKeys);
            reportedKeys.map(async (key) => {
                var details = await this.communityContract.methods
                    .getReport(key)
                    .call();
                console.log("`${details[0]}`: ", details);
                var resolvedReceipt = await this.communityContract.methods
                    .getResolvedReceipt(key)
                    .call();
                this.$store.state.reports.push({
                    title: details[1],
                    src: details[0],
                    description: details[2],
                    receipt: details[4],
                    resolved: details[6],
                    location: JSON.parse(details[5]),
                    resolvedLink: details[3],
                    resolvedReceipt: resolvedReceipt,
                });
            });
            this.isLoading = false;
        },
        startUpload: async function () {
            this.isLoading = true;
            await Promise.resolve(this.submit());
            this.isLoading = false;
        },
        submit: async function () {
            var contract = require("../embarkArtifacts/contracts/Community").default;
            console.log("contract: ", contract);
            if (this.$refs.form.validate() && this.files.length > 0) {
                console.log("valid: ", this.valid);
                let This = this;
                var links = [];
                return new Promise(async (resolve) => {
                    var counter = 0;

                    this.files.map((file) => {
                        let formData = new FormData();
                        formData.append("file", file);
                        axios
                            .post("https://siasky.net/skynet/skyfile", formData, {
                                headers: {
                                    "Content-Type": "multipart/form-data",
                                },
                            })
                            .then(async function (response) {
                                console.log(
                                    `Upload successful, skylink: https://siasky.net/${response.data.skylink}`
                                );
                                var receipt = await This.communityContract.methods
                                    .report(
                                        `https://siasky.net/${response.data.skylink}`,
                                        This.title,
                                        This.description,
                                        This.location.toString()
                                    )
                                    .send({
                                        gas: 6000000,
                                    });
                                console.log("receipt: ", receipt);
                                var updated = await contract.methods
                                    .addReceipt(
                                        `https://siasky.net/${response.data.skylink}`,
                                        `https://etherscan.io/tx/${receipt.transactionHash}`
                                    )
                                    .send({
                                        gas: 6000000,
                                    });
                                console.log(
                                    "currentCounter: ",
                                    counter,
                                    "counter>files: ",
                                    counter > This.files.length
                                );
                                if (counter === This.files.length - 1) {
                                    resolve(true);
                                    This.loadReports();
                                    This.success("Successfully uploaded files");
                                }
                                counter++;
                            })
                            .catch(function (error) {
                                console.log("error while uploading file: ", error);
                                This.error("Something went wrong whilst uploading video");
                                This.isLoading = false;
                                resolve(true);
                            });
                    });
                });
            } else {
                this.error("Missing form data");
            }
        },
        getLocation: async function () {
            try {
                this.location = await this.getUserLocation();
                this.location = JSON.stringify({
                    lat: this.location.coords.latitude,
                    longtitude: this.location.coords.longitude,
                });
                console.log("location: ", this.location);
            } catch (error) {
                console.log("error getting user location: ", error);
                this.error("Seems like your browser doesnt support GeoLocation");
            }
        },
        error(message) {
            swal.fire({
                icon: "error",
                text: message,
            });
        },
        success(message) {
            swal.fire({
                icon: "success",
                text: message,
            });
        },
        async getUserLocation() {
            return new Promise((resolve, reject) => {
                if (!("geolocation" in navigator)) {
                    reject(new Error("Geolocation is not available."));
                }
                navigator.geolocation.getCurrentPosition(
                    (pos) => {
                        resolve(pos);
                    },
                    (err) => {
                        reject(err);
                    }
                );
            });
        },
        successWithFooter(url) {
            swal.fire({
                title: "Success",
                icon: "success",
                html: "You can use this link to access your video, " +
                    `<a href="${url}">links</a> `,
                showCloseButton: true,
                confirmButtonAriaLabel: "great!",
                cancelButtonText: "Close",
            });
        },
    },
};
</script>
