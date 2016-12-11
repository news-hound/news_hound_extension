$( document ).ready(function() {

  $("#page-body").load("filters.html");

  $('#inputRowCheckbox1').click(function() {
    localStorage.setItem("ai_mode", true);
    localStorage.setItem("todos", false);
  });

  $('#openContactUs').click(function() {
    var win = window.open("https://htmlpreview.github.io/?https://github.com/madhurxyz/Ronin/blob/master/index.html#contact", '_blank');
    win.focus();
  });

  $('#showServices').click(function() {
    $("#page-body").load("section.html");
  });

});
