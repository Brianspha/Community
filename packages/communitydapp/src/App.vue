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
            <v-tab>Pending</v-tab>
            <v-tab>Resolved</v-tab>
            <v-tab-item key="1">
                <v-container fluid>
                    <v-row>
                        <v-col v-for="(report, i) in $store.state.reports" :key="i" cols="12" md="4">
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
                                    <v-btn v-if="!report.resolved"  color="orange" @click="openResolve(report)" text>Resolve</v-btn>
                                    <v-btn color="orange" @click="openMaps(report.location)" text>View on Map</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-col>
                    </v-row>
                </v-container>
            </v-tab-item>
        </v-tabs>
        <resolveModal/>
          <loading :active.sync="isLoading" :is-full-page="true" />
    </v-card>
    </template>
    </v-main>
</v-app>
</template>

<script>
import resolveModal from './components/ShowResolve'
import Loading from "vue-loading-overlay";
// Import stylesheet
import "vue-loading-overlay/dist/vue-loading.css";
import axios from "axios";
import swal from "sweetalert2";
export default {
    name: 'community',
    components: {resolveModal,        Loading
},
    data: () => ({
        communityContract: require("../embarkArtifacts/contracts/Community")
            .default,        isLoading: false
    }),
    mounted() {
      console.log('this: ',this)
        this.loadReports();
        // this.createDB();
    }  ,
    methods:{
      openResolve(report){
        this.$store.state.selectedReport=report
        this.$store.state.showResolve=true
      },

     goto(link) {
            console.log('going to: ', link)
            var win = window.open(link, '_blank');
            win.focus();
        },
        openMaps(geo) {
            var url =
                "http://www.google.com/maps/place/" +
                geo.lat +
                "," +
                geo.longtitude;
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
                var resolvedReceipt= await this.communityContract.methods
                    .getResolvedReceipt(key).call()
                this.$store.state.reports.push({
                    title: details[1],
                    src: details[0],
                    description: details[2],
                    receipt: details[4],
                    resolved: details[6],
                    location: JSON.parse(details[5]),
                    resolvedLink: details[3],
                    resolvedReceipt: resolvedReceipt
                });
            });
            this.isLoading = false;
        }
}
}
</script>
