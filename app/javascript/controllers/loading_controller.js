import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "loader"]

  submit(event) {
    // Empêche double clic
    this.buttonTarget.disabled = true
    // Affiche le loader
    this.loaderTarget.classList.add("show")
  }
}
