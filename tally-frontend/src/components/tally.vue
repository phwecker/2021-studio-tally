<template>
  <v-container :class="status" fluid style="height:100%">
    <v-row>
      <v-col>
        <div class="id">
          <b>CAMERA {{ id }}</b>
        </div>
        <div class="text">
          <b>{{ text }}</b>
        </div>
        <div class="ip">
          <i style="margin-right: 0.5em" v-for="item in ip" :key="item[0]">{{
            item[0]
          }}</i>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  name: "tallyComponent",
  props: {
    text: String,
    color: String,
    status: String,
    id: Number,
    ip: Object,
  },
  computed: {
    cssProps() {
      return {
        "tally-color": this.color,
      };
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.tally {
  background-color: white;
}
.id {
  width: 100%;
  text-align: center;
  font-size: 10em;
}
.text {
  width: 100%;
  text-align: center;
  font-size: 6em;
  position: absolute;
  bottom: 1em;
}
.ip {
  margin-left: auto;
  margin-right: auto;
  width: 100%;
  text-align: center;
  padding-right: 1em;
  font-size: 3em;
  position: absolute;
  bottom: 0.5em;
}
.program {
  background-color: red !important;
  color: white;
}
.preview {
  background-color: green;
  color: white;
}
.transition {
  background-color: yellow;
  color: black;
}
.off {
  background-color: gray;
  color: #666666;
}
</style>
