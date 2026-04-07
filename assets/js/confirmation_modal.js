// This logic is used to display a confirmation modal instead of the default
// confirmation window.
// It intercepts every phoenix.link.click and display a custom confirmation modal only
// if it's required by a data-confirm or the click does not come from the modal it self.
const resolvedAttr = "data-confirm-resolved";
const getElement = (suffix) => document.getElementById(`data-confirm-${suffix}`);
let target = null;

document.body.addEventListener(
  "phoenix.link.click",
  function (e) {
    e.stopPropagation();
    const message = e.target.getAttribute("data-confirm");
    if (!message) { return }

    target = e.target;

    // If the event is resolved (user click on a button in the Modal), then we don't intercept.
    if (e.target?.hasAttribute(resolvedAttr)) {
      e.target.removeAttribute(resolvedAttr);
      return;
    }

    e.preventDefault();
    e.target?.setAttribute(resolvedAttr, "");
    populateModal(e.target.dataset);

    getElement("modal").showModal();
  },
  false
);

window.addEventListener("data-confirm:confirm", () => {
  getElement("modal").close();
  target?.click();
  target = null;
})

window.addEventListener("data-confirm:cancel", () => {
  getElement("modal").close();
  target?.removeAttribute(resolvedAttr);
  target = null;
})

function populateModal(dataset) {
  getElement("message").innerHTML = dataset.confirm;
}
