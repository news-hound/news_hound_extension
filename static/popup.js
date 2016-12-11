function checkSetting(key) {
  return localStorage.getItem(key) == 'true'
}

$( document ).ready(function() {

  $('#inputRowCheckbox1').change(function() {
    localStorage.setItem("newshound", this.checked);
  })
  .prop('checked', checkSetting('newshound'));

  $('#inputRowCheckbox2').change(function() {
    localStorage.setItem("snopes", this.checked);
  })
  .prop('checked', checkSetting('snopes'));

  $('#inputRowCheckbox3').change(function() {
    localStorage.setItem("real_or_satire", this.checked);
  })
  .prop('checked', checkSetting('real_or_satire'));

  $('#inputRowCheckbox4').change(function() {
    localStorage.setItem("politifact", this.checked);
  })
  .prop('checked', checkSetting('politifact'));

  $('#openContactUs').click(function() {
    var win = window.open("https://htmlpreview.github.io/?https://github.com/madhurxyz/Ronin/blob/master/index.html#contact", '_blank');
    win.focus();
  });

  console.log('done');
});
