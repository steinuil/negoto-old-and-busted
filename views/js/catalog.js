function attachment_name() {
  var _ = document.getElementById('filei').value;
  if (_ !== '') {
    var n = _.split("\\");
    document.getElementById('file').textContent = n[n.length-1];
  }
}
