import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  toggle(event) {
    const clickedItem = event.currentTarget

    this.itemTargets.forEach(item => {
      const body = item.querySelector('.body')
      if (item === clickedItem) {
        body.classList.remove('collapse')
      } else {
        body.classList.add('collapse')
      }
    })
  }
}
