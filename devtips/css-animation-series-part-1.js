document.addEventListener('DOMContentLoaded', function() {
  document.querySelector(".trigger").addEventListener("click", function(event) {
    event.currentTarget.classList.toggle("clicked");
  });
});


