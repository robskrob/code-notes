document.addEventListener('DOMContentLoaded', function() {
  document.querySelector('.box').addEventListener("click", function(event) {
    event.currentTarget.classList.toggle("is-paused");
  });
});
