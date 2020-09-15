<template>
<v-app>
    <v-app-bar app color="black" dark>
        <v-btn text>
            <v-icon dark>mdi-room-service</v-icon>
        </v-btn>
        <v-toolbar-title>Community</v-toolbar-title>
    </v-app-bar>
    <v-card>
        <v-tabs background-color="white" color="deep-purple accent-4" right>
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
                                    <v-btn v-if="report.resolved" color="orange" @click="goto(report.receipt)" text>Details</v-btn>
                                    <v-btn color="orange" @click="openMaps(report.location)" text>View on Map</v-btn>
                                </v-card-actions>
                            </v-card>
                            </template>
                        </v-col>
                    </v-row>
                </v-container>
            </v-tab-item>
        </v-tabs>
    </v-card>
</v-app>
</template>

<script>
export default {
    name: 'App',

    components: {},

    data: () => ({
        //
    }),
};
</script>
