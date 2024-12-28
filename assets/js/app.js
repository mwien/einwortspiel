// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { QRCode } from "../vendor/qrcode.js";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

function checkdiff(el) {
  var hidden = el.querySelector(".hidden");
  var text = el.querySelector("input[type=text]");
  var submit = el.querySelector(".submit");
  if (text.value === hidden.textContent) {
    submit.style.visibility = "hidden";
    submit.setAttribute("disabled", "");
  } else {
    submit.style.visibility = "visible";
    submit.removeAttribute("disabled");
  }
}

function checkempty(el) {
  var text = el.querySelector("input[type=text]");
  var submit = el.querySelector(".submit");
  if (text.value.trim() === "") {
    submit.setAttribute("disabled", "");
    submit.style.backgroundColor = "#e5e7eb";
  } else {
    submit.removeAttribute("disabled");
    submit.style.backgroundColor = "white";
  }
}

// simple hooks for extremely basic textform validation on the client
// Diff hides and disables submit element exactly if value of first text input is equal to hidden elements value (allows enabling submit only for different inputs)
//
// Empty sets background to gray and disables submit element exactly if value of first text input is empty

let Hooks = {};
Hooks.Diff = {
  // is this possible without hidden span?
  mounted() {
    this.el.addEventListener("input", (e) => {
      checkdiff(this.el);
    });
  },
  updated() {
    checkdiff(this.el);
  },
};
Hooks.Empty = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      checkempty(this.el);
    });
  },
  updated() {
    checkempty(this.el);
  },
};

Hooks.GenQR = {
  mounted() {
    new QRCode(document.getElementById("qrcode"), {
      text: window.location.href,
      colorDark: "#000000",
      colorLight: "#ffffff",
      correctLevel: QRCode.CorrectLevel.M,
      useSVG: true,
    });
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 120);
  }
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

window.addEventListener("urlcopy", (event) =>
  navigator.clipboard.writeText(window.location.href),
);

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
