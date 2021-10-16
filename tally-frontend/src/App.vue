<template>
  <v-app>
    <v-main>
      <tallyComponent
        :id="tally.id"
        :text="tally.text"
        :status="tally.status"
        :ip="tally.ip"
      />
    </v-main>
  </v-app>
</template>

<script>
import tallyComponent from "./components/tally";

export default {
  name: "App",

  components: {
    tallyComponent,
  },

  data: () => ({
    tally: {
      id: 0,
      status: "off",
      text: "NOT SELECTED",
      color: "#666666",
      ip: ["A", "B"],
    },
  }),
  created: function() {
    this.fetchEventsList();
    this.timer = setInterval(this.fetchEventsList, 500);
  },
  methods: {
    async fetchEventsList() {
      await fetch("http://localhost:8081/tally").then((response) => {
        response.json().then((data) => {
          this.tally = data;
        });
      });
    },
    cancelAutoUpdate() {
      clearInterval(this.timer);
    },
  },
  beforeDestroy() {
    this.cancelAutoUpdate();
  },
};
</script>
