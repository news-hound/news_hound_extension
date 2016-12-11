function checkSetting(key, callback) {
  chrome.storage.sync.get(key, function(item) {
    callback (item);
  });
}

$( document ).ready(function() {

  function setValues(value) {
    var key = Object.keys(value)[0]
    $('#' + key).prop('checked', value[key]);
  }

  $('#newshound').change(function() {
    chrome.storage.sync.set({"newshound": this.checked}, function() {
      console.log('Settings saved');
    });
  })
  .prop('checked', checkSetting('newshound', setValues));

  $('#snopes').change(function() {
    chrome.storage.sync.set({"snopes": this.checked}, function() {
      console.log('Settings saved');
    });
  })
  .prop('checked', checkSetting('snopes', setValues));

  $('#real_or_satire').change(function() {
    chrome.storage.sync.set({"real_or_satire": this.checked}, function() {
      console.log('Settings saved');
    });
  })
  .prop('checked', checkSetting('real_or_satire', setValues));

  $('#politifact').change(function() {
    chrome.storage.sync.set({"politifact": this.checked}, function() {
      console.log('Settings saved');
    });
  })
  .prop('checked', checkSetting('politifact', setValues));

  $('#openContactUs').click(function() {
    var win = window.open("https://htmlpreview.github.io/?https://github.com/madhurxyz/Ronin/blob/master/index.html#contact", '_blank');
    win.focus();
  });

  console.log('done');
});
