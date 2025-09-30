import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault();
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime());
    this.containerTarget.insertAdjacentHTML("beforeend", content);
  }

  remove(event) {
    event.preventDefault();
    const wrapper = event.target.closest("[data-benefit-target='item']");
    if (wrapper) {
      const destroyInput = wrapper.querySelector("input[name*='_destroy']");
      if (destroyInput) {
        destroyInput.value = "1";
        wrapper.style.display = "none";
      } else {
        wrapper.remove();
      }
    }
  }
}