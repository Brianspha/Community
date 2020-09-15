<template>
  <v-row justify="center">

    <v-dialog
      v-model="$store.state.showResolve"
    >
      <v-card>
        <v-card-title class="headline">Resolve Incident</v-card-title>
        <v-card-text>
<v-form ref="form" v-model="valid" lazy-validation>
                                        <v-text-field v-model="$store.state.selectedReport.title" counter  label="Report Title" disabled></v-text-field>
                                        <v-textarea v-model="$store.state.selectedReport.description" solo name=" input-7-4" label="Description" counter disabled ></v-textarea>
                                        <v-file-input accept=
"application/msword, application/vnd.ms-excel, application/vnd.ms-powerpoint,
text/plain, application/pdf" v-model="files" color="black" counter label="Images"  placeholder="Upload Document" prepend-icon="mdi-paperclip" outlined :show-size="1000">
                                            <template v-slot:selection="{ index, text }">
                                                <v-chip v-if="index < 2" color="black" dark label small>{{ text }}</v-chip>
                                                <span v-else-if="index === 2" class="overline grey--text text--darken-3 mx-2">+{{ files.length - 2 }} File(s)</span>
                                            </template>
                                        </v-file-input>
                    
                                    </v-form>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="green darken-1"
            text
            @click="$store.state.showResolve=false"
          >
            Close
          </v-btn>

          <v-btn :disabled="files.length === 0" color="white" class="mr-4" @click="resolveIssue">Resolve</v-btn>
        </v-card-actions>
                  <loading :active.sync="isLoading" :is-full-page="true" />

      </v-card>
    </v-dialog>
  </v-row>
</template>

<script>
import Loading from "vue-loading-overlay";
// Import stylesheet
import "vue-loading-overlay/dist/vue-loading.css";
import axios from "axios";
import swal from "sweetalert2";
  export default {
    data () {
      return {
        dialog: false,
        isLoading:false,
        files:[],
         communityContract: require("../../embarkArtifacts/contracts/Community")
            .default
      }
    }, components: {Loading
},
    methods:{
        resolveIssue: async function(){
             this.isLoading = true;
                await this.submit()
                 this.isLoading = false;
        },
         submit: async function () {
            if (this.files) {
                console.log("valid: ", this.valid);
                let This = this;
                var links = [];
                return new Promise(async (resolve) => {
                    var counter = 0;
 let formData = new FormData();
                        formData.append("file", This.files);
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
                                var updated = await This.communityContract.methods
                                    .resolveReport(
                                        `https://siasky.net/${response.data.skylink}`,
                                       This.$store.state.selectedReport.src
                                    )
                                    .send({
                                        gas: 6000000,
                                    });
                                var receipt =  await This.communityContract.methods.addReceiptResolved(This.$store.state.selectedReport.src,`https://etherscan.io/tx/${updated.transactionHash}`).send({gas:6000000})
                             resolve(true);
                                    This.success("Successfully uploaded files");
                            })
                            .catch(function (error) {
                                console.log("error while uploading file: ", error);
                                This.error("Something went wrong whilst uploading video");
                                This.isLoading = false;
                                resolve(true);
                            });
                   
                });
            } else {
                this.error("Missing form data");
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
    }
  }
</script>